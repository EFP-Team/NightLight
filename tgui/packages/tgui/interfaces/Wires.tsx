import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  proper_name: string;
  wires: Wire[];
  status: string[];
};

type Wire = {
  color: string;
  cut: BooleanLike;
  attached: BooleanLike;
  wire: string;
};

export const Wires = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { proper_name, status = [], wires = [] } = data;
  const dynamicHeight = 150 + wires.length * 30 + (proper_name ? 30 : 0);

  return (
    <Window width={350} height={dynamicHeight}>
      <Window.Content>
        <Stack fill vertical>
          {!!proper_name && (
            <Stack.Item>
              <NoticeBox textAlign="center">
                {proper_name} Wire Configuration
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              <WireMap />
            </Section>
          </Stack.Item>
          {!!status.length && (
            <Stack.Item>
              <Section>
                {status.map((status) => (
                  <Box key={status}>{status}</Box>
                ))}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Returns a labeled list of wires */
const WireMap = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { wires } = data;

  return (
    <LabeledList>
      {wires.map((wire) => (
        <LabeledList.Item
          key={wire.color}
          className="candystripe"
          label={wire.color}
          labelColor={wire.color}
          color={wire.color}
          buttons={
            <>
              <Button
                content={wire.cut ? 'Mend' : 'Cut'}
                onClick={() =>
                  act('cut', {
                    wire: wire.color,
                  })
                }
              />
              <Button
                content="Pulse"
                onClick={() =>
                  act('pulse', {
                    wire: wire.color,
                  })
                }
              />
              <Button
                content={wire.attached ? 'Detach' : 'Attach'}
                onClick={() =>
                  act('attach', {
                    wire: wire.color,
                  })
                }
              />
            </>
          }
        >
          {!!wire.wire && <i>({wire.wire})</i>}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};
