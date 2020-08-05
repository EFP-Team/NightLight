/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'common/redux';
import { updateSettings } from './actions';
import { selectSettings } from './selectors';

export const useSettings = context => {
  const settings = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return {
    ...settings,
    update: obj => dispatch(updateSettings(obj)),
  };
};
