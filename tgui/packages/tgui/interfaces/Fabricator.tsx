import { useBackend, useLocalState, useSharedState } from '../backend';
import { Stack, Section, Button, Input, Icon, Tabs, Dimmer, Flex } from '../components';
import { Window } from '../layouts';
import { Material, MaterialAmount, MaterialFormatting, MATERIAL_KEYS, MaterialIcon } from './common/Materials';
import { sortBy } from 'common/collections';
import { formatSiUnit } from '../format';
import { Component, createRef } from 'inferno';

type MaterialMap = Partial<Record<keyof typeof MATERIAL_KEYS, number>>;

/**
 * A single design that the fabricator can print.
 */
type Design = {
  /**
   * The name of the design.
   */
  name: string;

  /**
   * A human-readable description of the design.
   */
  desc: string;

  /**
   * The individual material cost to print the design, adjusted for the
   * fabricator's part efficiency.
   */
  cost: MaterialMap;

  /**
   * A reference to the design's design datum.
   */
  id: string;

  /**
   * The categories the design should be present in.
   */
  categories?: string[];
};

type FabricatorData = {
  /**
   * The materials available to the fabricator, via ore silo or local storage.
   */
  materials: Material[];

  /**
   * The name of the fabricator, as displayed on the title bar.
   */
  fab_name: string;

  /**
   * Whether mineral access is disabled from the ore silo (contact the
   * quartermaster).
   */
  on_hold: boolean;

  /**
   * The set of designs that this fabricator can print, ordered by their ID.
   */
  designs: Record<string, Design>;

  /**
   * Whether the fabricator is currently printing an item.
   */
  busy: boolean;
};

/**
 * Categories present in this object are not rendered to the final fabricator
 * UI.
 */
const BLACKLISTED_CATEGORIES: Record<string, boolean> = {
  'initial': true,
  'core': true,
  'hacked': true,
};

/**
 * A dummy category that, when selected, renders ALL recipes to the UI.
 */
const ALL_CATEGORY = '__ALL';

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { materials, fab_name, on_hold, designs, busy } = data;

  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    'selected_category',
    ALL_CATEGORY
  );
  const [searchText, setSearchText] = useSharedState(
    context,
    'search_text',
    ''
  );

  // Sort the designs by name.
  const sortedDesigns = sortBy((design: Design) => design.name)(
    Object.values(designs)
  );

  // Find the number of items in each unique category, and the sum total of all
  // printable items.
  const categoryCounts: Record<string, number> = {};
  let totalRecipes = 0;

  for (const design of sortedDesigns) {
    totalRecipes += 1;

    for (const category of design.categories ?? []) {
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
  }

  // Strip blacklisted categories from the output.
  for (const blacklistedCategory in BLACKLISTED_CATEGORIES) {
    delete categoryCounts[blacklistedCategory];
  }

  // Reduce the material count array to a map of actually available materials.
  const availableMaterials: MaterialMap = {};

  for (const material of data.materials) {
    availableMaterials[material.name] = material.amount;
  }

  // Render all categories with items, sorted by name.
  const namedCategories = Object.keys(categoryCounts).sort();

  return (
    <Window title={data.fab_name} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width={'200px'}>
                <Section fill title="Categories" style={{ 'overflow': 'auto' }}>
                  <Tabs vertical>
                    <Tabs.Tab
                      fluid
                      selected={selectedCategory === ALL_CATEGORY}
                      onClick={() => {
                        setSelectedCategory(ALL_CATEGORY);
                        setSearchText('');
                      }}
                      color="transparent">
                      All Designs ({totalRecipes})
                    </Tabs.Tab>

                    {namedCategories.map((categoryName) => (
                      <Tabs.Tab
                        key={categoryName}
                        selected={selectedCategory === categoryName}
                        onClick={() => {
                          setSelectedCategory(categoryName);
                          setSearchText('');
                        }}
                        fluid
                        color="transparent">
                        {categoryName} ({categoryCounts[categoryName]})
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  title="Designs"
                  fill
                  buttons={
                    <Button
                      content="R&D Sync"
                      onClick={() => act('sync_rnd')}
                    />
                  }>
                  <Stack vertical fill>
                    <Stack.Item>
                      <Section>
                        <SearchBar
                          searchText={searchText}
                          setSearchText={setSearchText}
                        />
                      </Section>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Section fill scrollable>
                        {sortedDesigns
                          .filter(
                            (design) =>
                              selectedCategory === ALL_CATEGORY ||
                              design.categories?.indexOf(selectedCategory) !==
                                -1
                          )
                          .filter((design) =>
                            design.name.toLowerCase().includes(searchText)
                          )
                          .map((design) => (
                            <Recipe
                              key={design.name}
                              design={design}
                              available={availableMaterials}
                            />
                          ))}
                      </Section>
                      {!!busy && (
                        <Dimmer
                          style={{
                            'font-size': '2em',
                            'text-align': 'center',
                          }}>
                          <Icon name="cog" spin />
                          {' Building items...'}
                        </Dimmer>
                      )}
                    </Stack.Item>
                  </Stack>
                </Section>
                {!!on_hold && (
                  <Dimmer
                    style={{ 'font-size': '2em', 'text-align': 'center' }}>
                    Mineral access is on hold, please contact the quartermaster.
                  </Dimmer>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <MaterialBar
                materials={sortBy((a: Material) => a.name)(
                  data.materials ?? []
                )}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SearchBarProps = {
  searchText: string;
  setSearchText: (text: string) => void;
};

const SearchBar = (props: SearchBarProps, context) => {
  const { searchText, setSearchText } = props;

  return (
    <Stack align="baseline">
      <Stack.Item>
        <Icon name="search" />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          fluid
          placeholder="Search for..."
          onInput={(_e: unknown, v: string) => setSearchText(v.toLowerCase())}
          value={searchText}
        />
      </Stack.Item>
    </Stack>
  );
};

type MaterialCostProps = {
  design: Design;
  amount: number;
  available: MaterialMap;
};

const MaterialCost = (props: MaterialCostProps, context) => {
  const { design, amount, available } = props;

  return (
    <Stack wrap justify="space-around">
      {Object.entries(design.cost).map(([material, cost]) => (
        <Stack.Item key={material}>
          <MaterialAmount
            name={material as keyof typeof MATERIAL_KEYS}
            amount={cost * amount}
            formatting={MaterialFormatting.SIUnits}
            color={
              cost * amount > available[material]
                ? 'bad'
                : cost * amount * 2 > available[material]
                  ? 'average'
                  : 'normal'
            }
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

type PrintButtonProps = {
  design: Design;
  quantity: number;
  available: MaterialMap;
};

const PrintButton = (props: PrintButtonProps, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, quantity, available } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount * quantity > (available[material] ?? 0)
  );

  return (
    <Button
      className={`Fabricator__PrintAmount ${
        !canPrint ? 'Fabricator__PrintAmount--disabled' : ''
      }`}
      tooltip={
        <MaterialCost design={design} amount={quantity} available={available} />
      }
      color={'transparent'}
      onClick={() => act('build', { ref: design.id, amount: quantity })}>
      &times;{quantity}
    </Button>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { design, available } = props;

  const canPrint = !Object.entries(design.cost).some(
    ([material, amount]) =>
      !available[material] || amount > (available[material] ?? 0)
  );

  return (
    <div class="Fabricator__Recipe">
      <Stack justify="space-between" align="stretch">
        <Stack.Item>
          <Button
            icon="question-circle"
            color="transparent"
            tooltip={design.desc}
            tooltipPosition="left"
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            color={'transparent'}
            className={`Fabricator__Button ${
              !canPrint ? 'Fabricator__Button--disabled' : ''
            }`}
            fluid
            tooltip={
              <MaterialCost design={design} amount={1} available={available} />
            }
            onClick={() => act('build', { ref: design.id, amount: 1 })}>
            {design.name}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <PrintButton design={design} quantity={5} available={available} />
        </Stack.Item>
        <Stack.Item>
          <PrintButton design={design} quantity={10} available={available} />
        </Stack.Item>
      </Stack>
    </div>
  );
};

interface MaterialBarProps {
  materials: Material[];
}

const MaterialBar = (props: MaterialBarProps, context) => {
  const { materials } = props;

  return (
    <Flex wrap>
      {materials.map((material) => (
        <Flex.Item key={material.name} grow={1} shrink={1}>
          <MaterialCounter material={material} />
        </Flex.Item>
      ))}
    </Flex>
  );
};

interface MaterialCounterProps {
  material: Material;
}

const MaterialCounter = (props: MaterialCounterProps, context) => {
  const { material } = props;
  const { act } = useBackend<FabricatorData>(context);

  const [hovering, setHovering] = useLocalState(
    context,
    `MaterialCounter${material.name}`,
    false
  );

  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={`MaterialDock ${hovering ? 'MaterialDock--active' : ''}`}>
      <Stack vertial direction={'column-reverse'}>
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => act('remove_mat', { ref: material.ref, amount: 1 })}>
          <Flex.Item>
            <MaterialIcon material={material.name} />
          </Flex.Item>
          <Flex.Item>
            <AnimatedQuantityLabel targetValue={material.amount} />
          </Flex.Item>
        </Flex>
        {hovering && (
          <div className={'MaterialDock__Dock'}>
            <Flex vertical direction={'column-reverse'}>
              <EjectButton
                material={material}
                available={material.amount}
                amount={5}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={10}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={25}
              />
              <EjectButton
                material={material}
                available={material.amount}
                amount={50}
              />
            </Flex>
          </div>
        )}
      </Stack>
    </div>
  );
};

interface EjectButtonProps {
  material: Material;
  available: number;
  amount: number;
}

const EjectButton = (props: EjectButtonProps, context) => {
  const { amount, available, material } = props;
  const { act } = useBackend<FabricatorData>(context);

  return (
    <Button
      fluid
      color={'transparent'}
      onClick={() => act('remove_mat', { ref: material.ref, amount })}
      className={`Fabricator__PrintAmount ${
        amount * 2_000 > available ? 'Fabricator__PrintAmount--disabled' : ''
      }`}>
      &times;{amount}
    </Button>
  );
};

interface AnimatedLabelProps {
  targetValue: number;
}

class AnimatedQuantityLabel extends Component<AnimatedLabelProps> {
  protected ref = createRef<HTMLSpanElement>();
  protected interval?: NodeJS.Timeout;
  protected currentValue: number = 0;

  constructor(props: AnimatedLabelProps) {
    super(props);

    this.currentValue = props.targetValue;
  }

  componentWillUnmount() {
    this.stopTicking();
  }

  shouldComponentUpdate(newProps: AnimatedLabelProps) {
    if (newProps.targetValue !== this.props.targetValue) {
      this.startTicking();
    }

    return false;
  }

  protected startTicking() {
    this.stopTicking();

    this.interval = setInterval(() => this.tick(), 100);
  }

  protected stopTicking() {
    this.interval ?? clearInterval(this.interval);
  }

  protected tick() {
    const { currentValue } = this;
    const { targetValue } = this.props;

    this.currentValue = currentValue * 0.875 + targetValue * 0.125;

    if (Math.abs(targetValue - currentValue) < 1) {
      this.stopTicking();
    }

    if (this.ref.current) {
      this.ref.current.innerText = formatSiUnit(this.currentValue, 0);
    }
  }

  render() {
    return <span ref={this.ref}>{formatSiUnit(this.currentValue, 0)}</span>;
  }
}
