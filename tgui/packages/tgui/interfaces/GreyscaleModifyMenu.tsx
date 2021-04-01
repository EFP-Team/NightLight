import { useBackend } from '../backend';
import { Box, Button, ColorBox, Flex, Icon, Input, LabeledList, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type ColorEntry = {
  index: Number;
  value: string;
}

type SpriteData = {
  finished: SpriteEntry
  steps: Array<SpriteEntry>
}

type SpriteEntry = {
  layer: string
  result: string
}

type GreyscaleMenuData = {
  colors: Array<ColorEntry>;
  sprites: SpriteData;
}

const ColorDisplay = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  const colors = (data.colors || []);
  return (
    <Section title='Colors'>
      <LabeledList>
        <LabeledList.Item
          key='fullstring'
          label='Full Color String'>
          <Input
            value={colors.map(item => item.value).join('')}
            onChange={(_, value) => act("recolor_from_string", {color_string: value})}
          />
        </LabeledList.Item>
        {colors.map(item => (
          <LabeledList.Item
            key={item.index.toString()}
            label={`Color Group ${item.index}`}
            color={item.value}
          >
            <ColorBox
              color={item.value}
            />
            {" "}
            <Button
              content={<Icon name='palette'/>}
              onClick={() => act("pick_color", {color_index: item.index})}
            />
            <Input
              value={item.value}
              onChange={(_, value) => act("recolor", {color_index: item.index, new_color: value})}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewDisplay = (props, context) => {
  const { data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Section title='Preview'>
      <Table>
        <Table.Row header>
          <Table.Cell><Box textAlign='center' bold>Step Layer</Box></Table.Cell>
          <Table.Cell><Box textAlign='center' bold>Step Result</Box></Table.Cell>
        </Table.Row>
        {data.sprites.steps.map(item => (
          <Table.Row>
            <Table.Cell width='50%'><SingleSprite source={item.result}/></Table.Cell>
            <Table.Cell width='50%'><SingleSprite source={item.layer}/></Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  )
}

const SingleSprite = (props): JSX.Element => {
  const {
    source
  } = props
  return <Box
      as='img'
      class='icon icon-misc'
      src={source}
      width="100%"
    />
}

export const GreyscaleModifyMenu = (props, context) => {
  const { act, data } = useBackend<GreyscaleMenuData>(context);
  return (
    <Window title="Greyscale Modification">
      <Window.Content scrollable>
        <ColorDisplay/>
        <Button
          content='Refresh Icon File'
          onClick={() => act("refresh_file")}
        />
        {" "}
        <Button
          content='Apply'
          onClick={() => act("apply")}
        />
        <PreviewDisplay/>
      </Window.Content>
    </Window>
  );
};
