import { multiline } from 'common/string';
import { useAtom } from 'jotai';

import { useBackend } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { REVERSE_OPTIONS } from './constants';
import { tabAtom } from './hooks';
import { PodLauncherData } from './types';

export function ReverseMenu(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const {
    customDropoff,
    effectReverse,
    picking_dropoff_turf,
    reverse_option_list,
  } = data;

  const [tab, setTab] = useAtom(tabAtom);

  return (
    <Section
      fill
      title="Reverse"
      buttons={
        <Button
          icon={effectReverse ? 'toggle-on' : 'toggle-off'}
          onClick={() => {
            act('effectReverse');
            if (tab === 2) {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
          selected={effectReverse}
          tooltip={multiline`
            Doesn't send items.
            Afer landing, returns to
            dropoff turf (or bay
            if none specified).`}
        />
      }
    >
      {!!effectReverse && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              disabled={!effectReverse}
              onClick={() => act('pickDropoffTurf')}
              selected={picking_dropoff_turf}
              tooltip={multiline`
                Where reverse pods
                go after landing`}
              tooltipPosition="bottom-end"
            >
              Dropoff Turf
            </Button>
            <Button
              disabled={!customDropoff}
              icon="trash"
              inline
              onClick={() => {
                act('clearDropoffTurf');
                if (tab === 2) {
                  setTab(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
              tooltip={multiline`
                Clears the custom dropoff
                location. Reverse pods will
                instead dropoff at the
                selected bay.`}
              tooltipPosition="bottom"
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                disabled={!effectReverse}
                key={i}
                icon={option.icon}
                inline
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key || option.title,
                  })
                }
                selected={
                  option.key
                    ? reverse_option_list[option.key]
                    : reverse_option_list[option.title]
                }
                tooltip={option.title}
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}
