/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_MEMORY = 0;
export const IMPL_LOCAL_STORAGE = 1;
export const IMPL_INDEXED_DB = 2;

const INDEXED_DB_VERSION = 1;
const INDEXED_DB_NAME = 'tgui';
const INDEXED_DB_STORE_NAME = 'storage-v1';

const READ_ONLY = 'readonly';
const READ_WRITE = 'readwrite';

const testGeneric = testFn => () => {
  try {
    return Boolean(testFn());
  }
  catch {
    return false;
  }
};

// Localstorage can sometimes throw an error, even if DOM storage is not
// disabled in IE11 settings.
// See: https://superuser.com/questions/1080011
const testLocalStorage = testGeneric(() => (
  window.localStorage && window.localStorage.getItem
));

const testIndexedDb = testGeneric(() => (
  (window.indexedDB || window.msIndexedDB)
  && (window.IDBTransaction || window.msIDBTransaction)
));

class MemoryBackend {
  constructor() {
    this.impl = IMPL_MEMORY;
    this.store = {};
  }

  async get(key) {
    return this.store[key];
  }

  async set(key, value) {
    this.store[key] = value;
  }

  async remove(key) {
    this.store[key] = undefined;
  }

  async clear() {
    this.store = {};
  }
}

class LocalStorageBackend {
  constructor() {
    this.impl = IMPL_LOCAL_STORAGE;
    this.store = {};
  }

  async get(key) {
    const value = localStorage.getItem(key);
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
  }

  async set(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  async remove(key) {
    localStorage.removeItem(key);
  }

  async clear() {
    localStorage.clear();
  }
}

class IndexedDbBackend {
  constructor() {
    this.impl = IMPL_INDEXED_DB;
    /** @type {Promise<IDBDatabase>} */
    this.dbPromise = new Promise((resolve, reject) => {
      // window.indexedDB.deleteDatabase(INDEXED_DB_NAME);
      const req = window.indexedDB.open(
        INDEXED_DB_NAME, INDEXED_DB_VERSION);
      req.onupgradeneeded = () => {
        try {
          req.result.createObjectStore(INDEXED_DB_STORE_NAME);
        }
        catch (err) {
          reject(new Error('Failed to upgrade IDB: ' + req.error));
        }
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => {
        reject(new Error('Failed to open IDB: ' + req.error));
      };
    });
  }

  getStore(mode) {
    return this.dbPromise.then(db => db
      .transaction(INDEXED_DB_STORE_NAME, mode)
      .objectStore(INDEXED_DB_STORE_NAME));
  }

  async get(key) {
    const store = await this.getStore(READ_ONLY);
    return new Promise((resolve, reject) => {
      const req = store.get(key);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }

  async set(key, value) {
    // The reason we don't _save_ null is because IE 10 does
    // not support saving the `null` type in IndexedDB. How
    // ironic, given the bug below!
    // See: https://github.com/mozilla/localForage/issues/161
    if (value === null) {
      value = undefined;
    }
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.put(value, key);
  }

  async remove(key) {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.delete(key);
  }

  async clear() {
    // NOTE: We deliberately make this operation transactionless
    const store = await this.getStore(READ_WRITE);
    store.clear();
  }
}

export const storage = (
  testIndexedDb() && new IndexedDbBackend()
  || testLocalStorage() && new LocalStorageBackend()
  || new MemoryBackend()
);
