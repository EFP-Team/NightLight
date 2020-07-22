import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Table } from '../components';
import { Window } from '../layouts';

export const AtmosControlPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const groups = flow([
    map((group, i) => ({
      ...group,
      // Generate a unique id
      id: group.area + i,
    })),
    sortBy(group => group.id),
  ])(data.excited_groups);
  return (
    <Window
      title="SSAir Control Panel"
      width={650}
      height={500}
      resizable>
      <Section>
        <Flex justify="space-between">
          <Flex.Item>
            <Button
              onClick={() => act('toggle-freeze')}
              color={data.frozen === 1 ? 'good' : 'bad'}>
              {data.frozen === 1
                ? 'Freeze Subsystem'
                : 'Unfreeze Subsystem'}
            </Button>
          </Flex.Item>
          <Flex.Item>
            Active Turfs: {data.active_size}
          </Flex.Item>
          <Flex.Item>
            Hotspots: {data.hotspots_size}
          </Flex.Item>
          <Flex.Item>
            Excited Groups: {data.excited_size}
          </Flex.Item>
          <Flex.Item>
            <Button.Checkbox
              checked={data.show_all}
              onClick={() => act('toggle_show_all')}>
              Display all
            </Button.Checkbox>
          </Flex.Item>
        </Flex>
      </Section>
      <Box fillPositionedParent top="45px">
        <Window.Content scrollable>
          <Section>
            <Table>
              <Table.Row header>
                <Table.Cell>
                  Area Name
                </Table.Cell>
                <Table.Cell>
                  Breakdown Counter
                </Table.Cell>
                <Table.Cell>
                  Dismantle Counter
                </Table.Cell>
                <Table.Cell>
                  Tile Count
                </Table.Cell>
                <Table.Cell>
                  Display
                </Table.Cell>
              </Table.Row>
              {groups.map(group => (
                <tr key={group.id}>
                  <td>
                    <Button
                      content={group.area}
                      onClick={() => act('move-to-target', {
                        spot: group.jump_to,
                      })} />
                  </td>
                  <td>
                    {group.breakdown}
                  </td>
                  <td>
                    {group.dismantle}
                  </td>
                  <td>
                    {group.size}
                  </td>
                  <td>
                    <Button.Checkbox
                      checked={group.should_show}
                      onClick={() => act('toggle_show_group', {
                        group: group.group,
                      })} />
                  </td>
                </tr>
              ))}
            </Table>
          </Section>
        </Window.Content>
      </Box>
    </Window>
  );
};
