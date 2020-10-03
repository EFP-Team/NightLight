import { useBackend, useLocalState } from '../backend';
import { Button, Box, Section, Knob, Flex, LabeledControls, Divider } from '../components';
import { Window } from '../layouts';

export const TrainingMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    speed,
    setSpeed,
  ] = useLocalState(context, 'speed', 1);
  const [
    range,
    setRange,
  ] = useLocalState(context, 'range', 1);
  return (
    <Window
      width={230}
      height={150}
      title="AURUMILL">
      <Window.Content>
        <Section fill title="Training Machine">
          <LabeledControls m={1}>
            <LabeledControls.Item label="Speed">
              <Knob
                inline
                size={1.2}
                step={.5}
                stepPixelSize={10}
                value={speed}
                minValue={1}
                maxValue={10}
                onDrag={(e, value) => {
                  act("movespeed", { movespeed: value });
                  setSpeed(value);
                }} />
            </LabeledControls.Item>
            <LabeledControls.Item label="Range">
              <Knob
                inline
                size={1.2}
                step={1}
                stepPixelSize={51}
                value={range}
                minValue={1}
                maxValue={7}
                onDrag={(e, value) => {
                  act("range", { range: value });
                  setRange(value);
                }} />
            </LabeledControls.Item>
            <Flex.Item>
              <Divider vertical />
            </Flex.Item>
            <Flex.Item label="Simulation">
              <Button
                fluid
                selected={data.moving}
                content={(
                  <Box
                    bold
                    fontSize="1.4em"
                    lineHeight={3}>
                    {data.moving ? "END" : "BEGIN"}
                  </Box>
                )}
                onClick={() => act('toggle')}
              />
            </Flex.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
