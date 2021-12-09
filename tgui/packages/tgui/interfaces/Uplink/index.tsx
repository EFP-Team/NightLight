import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GenericUplink, Item } from './GenericUplink';
import { Component } from 'inferno';
import { fetchRetry } from '../../http';
import { resolveAsset } from '../../assets';
import { BooleanLike } from 'common/react';
import { Box, Tabs, Button, Stack, Section, Tooltip } from '../../components';
import { Objective, ObjectiveMenu } from './ObjectiveMenu';
import { calculateReputationLevel, reputationDefault, reputationLevelsTooltip } from './calculateReputationLevel';

type UplinkItem = {
  id: string,
  name: string,
  cost: number,
  desc: string,
  category: string,
  purchasable_from: number,
  restricted: BooleanLike,
  limited_stock: number,
  restricted_roles: string,
  progression_minimum: number,
}

export type ObjectiveUiButton = {
  name: string,
  tooltip: string,
  icon: string,
  action: string,
}

type UplinkData = {
  telecrystals: number,
  progression_points: number,
  uplink_flag: number,
  assigned_role: string,
  debug: BooleanLike,
  has_objectives: BooleanLike,
  has_progression: BooleanLike,
  potential_objectives: Objective[],
  active_objectives: Objective[],
  maximum_active_objectives: number,
}

type UplinkState = {
  allItems: UplinkItem[],
  allCategories: string[],
  currentTab: number,
}

type ServerData = {
  items: UplinkItem[],
  categories: string[],
}

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class Uplink extends Component<{}, UplinkState> {
  constructor() {
    super();
    this.state = {
      allItems: [],
      allCategories: [],
      currentTab: 0,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset("uplink.json"))
        .then(response => response.json());
    }
    const { data } = useBackend<UplinkData>(this.context);

    const uplinkFlag = data.uplink_flag;
    const uplinkRole = data.assigned_role;

    const uplinkData = await fetchServerData;
    uplinkData.items = uplinkData.items.sort((a, b) => {
      if (a.progression_minimum < b.progression_minimum) {
        return -1;
      }
      if (a.progression_minimum > b.progression_minimum) {
        return 1;
      }
      return 0;
    });

    const availableCategories: string[] = [];
    uplinkData.items = uplinkData.items.filter(value => {
      if (value.restricted_roles.length > 0
        && !value.restricted_roles.includes(uplinkRole)) {
        return false;
      }
      { if (value.purchasable_from & uplinkFlag) {
        if (!availableCategories.includes(value.category)) {
          availableCategories.push(value.category);
        }
        return true;
      } }
      return false;
    });

    uplinkData.categories = uplinkData.categories.filter(value =>
      availableCategories.includes(value));

    this.setState({
      allItems: uplinkData.items,
      allCategories: uplinkData.categories,
    });
  }

  render() {
    const { data, act } = useBackend<UplinkData>(this.context);
    const {
      telecrystals,
      progression_points,
      active_objectives,
      potential_objectives,
      has_objectives,
      has_progression,
      maximum_active_objectives,
    } = data;
    const {
      allItems,
      allCategories,
      currentTab,
    } = this.state as UplinkState;
    const items: Item[] = [];
    for (let i = 0; i < allItems.length; i++) {
      const item = allItems[i];
      const canBuy = telecrystals >= item.cost;
      const hasEnoughProgression
        = progression_points >= item.progression_minimum;
      items.push({
        id: item.id,
        name: item.name,
        category: item.category,
        desc: (
          <Box>
            {item.desc}
          </Box>
        ),
        cost: (
          <Box>
            {item.cost} TC
            {has_progression
              ? (
                <>
                  ,&nbsp;
                  <Box as="span">
                    {calculateReputationLevel(item.progression_minimum, true)}
                  </Box>
                </>
              )
              : ""}
          </Box>
        ),
        disabled: !canBuy || !hasEnoughProgression,
      });
    }
    return (
      <Window
        width={620}
        height={580}
        theme="syndicate">
        <Window.Content scrollable={currentTab !== 0}>
          <Stack vertical fill>
            <Stack.Item>
              <Section>
                <Stack>
                  <Stack.Item grow={1} align="center">
                    <Box fontSize={0.8}>
                      SyndOS Version 3.17 &nbsp;
                      <Box color="green" as="span">
                        Connection Secure
                      </Box>
                    </Box>
                    <Box color="green" bold fontSize={1.2}>
                      WELCOME, AGENT.
                    </Box>
                  </Stack.Item>
                  <Stack.Item align="center">
                    <Box bold fontSize={1.2}>
                      <Tooltip content={reputationLevelsTooltip}>
                        {/* If we have no progression,
                      just give them a generic title */}
                        {has_progression
                          ? calculateReputationLevel(progression_points, false)
                          : calculateReputationLevel(reputationDefault, false)}
                      </Tooltip>
                    </Box>
                    <Box color="good" bold fontSize={1.2} textAlign="right">
                      {telecrystals} TC
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fitted>
                <Stack align="center">
                  <Stack.Item grow={1}>
                    <Tabs fluid textAlign="center">
                      {!!has_objectives && (
                        <Tabs.Tab
                          selected={currentTab === 0}
                          onClick={() => this.setState({ currentTab: 0 })}
                        >
                          Objectives
                        </Tabs.Tab>
                      )}
                      <Tabs.Tab
                        selected={currentTab === 1 || !has_objectives}
                        onClick={() => this.setState({ currentTab: 1 })}
                      >
                        Market
                      </Tabs.Tab>
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item mr={1}>
                    <Button
                      icon="times"
                      content="Lock"
                      color="transparent"
                      onClick={() => act("lock")}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              {(currentTab === 0 && has_objectives) && (
                <ObjectiveMenu
                  activeObjectives={active_objectives}
                  potentialObjectives={potential_objectives}
                  maximumActiveObjectives={maximum_active_objectives}
                  handleObjectiveAction={(objective, action) =>
                    act("objective_act", { objective_action: action, index: objective.id, name: objective.name })}
                  handleStartObjective={(objective) => act("start_objective", { index: objective.id, name: objective.name })}
                  handleObjectiveCompleted={(objective) => act("finish_objective", { index: objective.id, name: objective.name })}
                />
              ) || (
                <GenericUplink
                  currency=""
                  categories={allCategories}
                  items={items}
                  handleBuy={(item) => {
                    act("buy", { path: item.id });
                  }}
                />
              )}
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

}


