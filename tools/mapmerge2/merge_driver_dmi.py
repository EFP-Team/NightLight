#!/usr/bin/env python3
import sys
import dmi

def images_equal(left, right):
    if left.size != right.size:
        return False
    w, h = left.size
    left_load, right_load = left.load(), right.load()
    for y in range(0, h):
        for x in range(0, w):
            if left_load[x,y] != right_load[x,y]:
                print(x, y)
                return False
    return True

def states_equal(left, right):
    # basic properties
    if (left.loop != right.loop
            or left.rewind != right.rewind
            or left.movement != right.movement
            or left.dirs != right.dirs
            or left.delays != right.delays
            or left.hotspots != right.hotspots):
        print("properties")
        return False

    # frames
    if len(left.frames) != len(right.frames):
        print("len frames")
        return False
    for (left_frame, right_frame) in zip(left.frames, right.frames):
        if not images_equal(left_frame, right_frame):
            return False

    return True

def three_way_merge(base, left, right):
    base_dims = base.width, base.height
    if base_dims != (left.width, left.height) or base_dims != (right.width, right.height):
        print("Dimensions have changed:")
        print(f"    Base: {base.width} x {base.height}")
        print(f"    Ours: {left.width} x {left.height}")
        print(f"    Theirs: {right.width} x {right.height}")
        return None

    base_states = {state.name: state for state in base.states}
    left_states = {state.name: state for state in left.states}
    right_states = {state.name: state for state in right.states}

    if len(base_states) != len(base.states) or len(left_states) != len(left.states) or len(right_states) != len(right.states):
        # TODO: take the "movement" flag into account here
        print("Duplicate state names not yet supported")
        return None

    new_left = {k: v for k, v in left_states.items() if k not in base_states}
    new_right = {k: v for k, v in right_states.items() if k not in base_states}
    for key, state in new_left.items():
        in_right = new_right.get(key, None)
        if in_right:
            if states_equal(state, in_right):
                # Allow it, but don't add it a second time
                del new_right[key]
            else:
                print(f"Added in both: {key!r}")
                return None

    final_states = []
    # add states that are currently in the base
    for state in base.states:
        in_left = left_states.get(state.name, None)
        in_right = right_states.get(state.name, None)
        left_equals = in_left and states_equal(state, in_left)
        right_equals = in_right and states_equal(state, in_right)

        if not in_left and not in_right:
            # deleted in both left and right, it's just deleted
            print(f"Deleted in both: {state.name!r}")
        elif not in_left:
            # left deletes
            print(f"Deleted in left: {state.name!r}")
            if not right_equals:
                print(f"... but modified in right")
                final_states.append(in_right)
        elif not in_right:
            # right deletes
            print(f"Deleted in right: {state.name!r}")
            if not left_equals:
                print(f"... but modified in left")
                final_states.append(in_left)
        elif left_equals and right_equals:
            # changed in neither
            #print(f"Same in both: {state.name!r}")
            final_states.append(state)
        elif left_equals:
            # changed only in right
            print(f"Changed in left: {state.name!r}")
            final_states.append(in_right)
        elif right_equals:
            # changed only in left
            print(f"Changed in right: {state.name!r}")
            final_states.append(in_left)
        else:
            # changed in both
            print(f"Changed in both: {state.name!r}")
            return None

    # add states that are brand-new in the left
    for key, state in new_left.items():
        #print(f"Added in left: {key!r}")
        final_states.append(state)

    # add states that are brand-new in the right
    for key, state in new_right.items():
        #print(f"Added in right: {key!r}")
        final_states.append(state)

    merged = dmi.Dmi(base.width, base.height)
    merged.states = final_states
    return merged

def main(path, original, left, right):
    print(f"Merging icon: {path}")

    icon_orig = dmi.Dmi.from_file(original)
    icon_left = dmi.Dmi.from_file(left)
    icon_right = dmi.Dmi.from_file(right)

    merged = three_way_merge(icon_orig, icon_left, icon_right)
    if merged is None:
        print("Manual merge required!")
        print("    ")
        return 1
    else:
        merged.to_file(left)
        return 0

if __name__ == '__main__':
    if len(sys.argv) != 6:
        print("DMI merge driver called with wrong number of arguments")
        print("    usage: merge-driver-dmi %P %O %A %B %L")
        exit(1)

    # "left" is also the file that ought to be overwritten
    _, path, original, left, right, conflict_size_marker = sys.argv
    exit(main(path, original, left, right))
