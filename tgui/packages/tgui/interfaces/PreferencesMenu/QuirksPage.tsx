import { Component, StatelessComponent } from "inferno";
import { Box, Icon, Stack, Table, Tooltip } from "../../components";
import { resolveAsset } from "../../assets";
import { classes } from "common/react";
import { PreferencesMenuData, Quirk } from "./data";
import { useBackend } from "../../backend";
import { logger } from "../../logging";
import { ServerPreferencesFetcher } from "./ServerPreferencesFetcher";

type QuirksPageState = {
  selectedQuirks: string[];
};

const getValueClass = (value: number): string => {
  if (value > 0) {
    return "positive";
  } else if (value < 0) {
    return "negative";
  } else {
    return "neutral";
  }
};

const QuirkList = (props: {
  quirks: [string, Quirk & {
    failTooltip?: string;
  }][],
  onClick: (quirkName: string, quirk: Quirk) => void,
}) => {
  return (
    // Stack is not used here for a variety of IE flex bugs
    <Box className="PreferencesMenu__Quirks__QuirkList">
      {props.quirks.map(([quirkKey, quirk]) => {
        const className = "PreferencesMenu__Quirks__QuirkList__quirk";

        const child = (
          <Box
            className={className}
            key={quirkKey}
            role="button"
            tabIndex="1"
            onClick={() => {
              props.onClick(quirkKey, quirk);
            }}
          >
            <Stack fill>
              <Stack.Item align="center">
                <Box className={classes(["quirks64x64", quirkKey])} />
              </Stack.Item>

              <Stack.Item align="stretch" style={{
                "border-right": "1px solid black",
                "margin-left": 0,
              }} />

              <Stack.Item grow style={{
                "margin-left": 0,

                // Fixes an IE bug for text overflowing in Flex boxes
                "min-width": "0%",
              }}>
                <Stack vertical fill>
                  <Stack.Item
                    className={
                      `${className}--${getValueClass(quirk.value)}`
                    }
                    style={{
                      "border-bottom": "1px solid black",
                      "padding": "2px",
                    }}
                  >
                    <Stack fill style={{
                      "font-size": "1.2em",
                    }}>
                      <Stack.Item grow>
                        <b>{quirk.name}</b>
                      </Stack.Item>

                      <Stack.Item>
                        <b>{quirk.value}</b>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>

                  <Stack.Item grow style={{
                    "margin-top": 0,
                    "padding": "3px",
                  }}>
                    {quirk.description}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        );

        if (quirk.failTooltip) {
          return (
            <Tooltip content={quirk.failTooltip}>
              {child}
            </Tooltip>
          );
        } else {
          return child;
        }
      })}
    </Box>
  );
};

const StatDisplay: StatelessComponent<{}> = (props) => {
  return (
    <Box
      backgroundColor="#eee"
      bold
      color="black"
      fontSize="1.2em"
      px={3}
      py={0.5}
    >
      {props.children}
    </Box>
  );
};

export class QuirksPage extends Component<{}, QuirksPageState> {
  state: QuirksPageState = {
    selectedQuirks: [],
  }

  componentDidMount() {
    this.populateSelectedQuirks();
  }

  populateSelectedQuirks() {
    const { data } = useBackend<PreferencesMenuData>(this.context);

    this.setState({
      selectedQuirks: data.selected_quirks,
    });
  }

  render() {
    const { act } = useBackend<PreferencesMenuData>(this.context);

    return (
      <ServerPreferencesFetcher
        render={data => {
          if (!data) {
            return <Box>Loading quirks...</Box>;
          }

          const {
            max_positive_quirks: maxPositiveQuirks,
            quirk_blacklist: quirkBlacklist,
            quirk_info: quirkInfo,
          } = data.quirks;

          const quirks = Object.entries(quirkInfo);
          quirks.sort(([_, quirkA], [__, quirkB]) => {
            if (quirkA.value === quirkB.value) {
              return (quirkA.name > quirkB.name) ? 1 : -1;
            } else {
              return quirkA.value - quirkB.value;
            }
          });

          let balance = 0;
          let positiveQuirks = 0;

          for (const selectedQuirkName of this.state.selectedQuirks) {
            const selectedQuirk = quirkInfo[selectedQuirkName];
            if (!selectedQuirk) {
              continue;
            }

            if (selectedQuirk.value > 0) {
              positiveQuirks += 1;
            }

            balance += selectedQuirk.value;
          }

          const getReasonToNotAdd = (quirkName: string) => {
            const quirk = quirkInfo[quirkName];

            if (
              quirk.value > 0
            ) {
              if (positiveQuirks >= maxPositiveQuirks) {
                return "You can't have any more positive quirks!";
              } else if (balance + quirk.value > 0) {
                return "You need a negative quirk to balance this out!";
              }
            }

            const selectedQuirks = this.state.selectedQuirks.map(quirkKey => {
              return quirkInfo[quirkKey].name;
            });

            for (const blacklist of quirkBlacklist) {
              if (blacklist.indexOf(quirk.name) === -1) {
                continue;
              }

              for (const incompatibleQuirk of blacklist) {
                if (
                  incompatibleQuirk !== quirk.name
                && selectedQuirks.indexOf(incompatibleQuirk) !== -1
                ) {
                  return `This is incompatible with ${incompatibleQuirk}!`;
                }
              }
            }

            return undefined;
          };

          const getReasonToNotRemove = (quirkName: string) => {
            const quirk = quirkInfo[quirkName];

            if (balance - quirk.value > 0) {
              return "You need to remove a negative quirk first!";
            }

            return undefined;
          };

          return (
            <Stack align="center" fill>
              <Stack.Item basis="50%">
                <Stack vertical fill align="center">
                  <Stack.Item>
                    <Box fontSize="1.3em">
                      Positive Quirks
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <StatDisplay>
                      {positiveQuirks} / {maxPositiveQuirks}
                    </StatDisplay>
                  </Stack.Item>

                  <Stack.Item>
                    <Box as="b" fontSize="1.6em">
                      Available Quirks
                    </Box>
                  </Stack.Item>

                  <Stack.Item grow width="100%">
                    <QuirkList
                      onClick={(quirkName, quirk) => {
                        if (getReasonToNotAdd(quirkName) !== undefined) {
                          return;
                        }

                        this.setState(oldState => {
                          return {
                            selectedQuirks:
                              oldState.selectedQuirks.concat(quirkName),
                          };
                        });

                        act("give_quirk", { quirk: quirk.name });
                      }}
                      quirks={quirks.filter(([quirkName, _]) => {
                        return this.state.selectedQuirks
                          .indexOf(quirkName) === -1;
                      }).map(([quirkName, quirk]) => {
                        return [quirkName, {
                          ...quirk,
                          failTooltip: getReasonToNotAdd(quirkName),
                        }];
                      })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item>
                <Icon
                  name="exchange-alt"
                  size={1.5}
                  ml={2}
                  mr={2}
                />
              </Stack.Item>

              <Stack.Item basis="50%">
                <Stack vertical fill align="center">
                  <Stack.Item>
                    <Box fontSize="1.3em">
                      Quirk Balance
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <StatDisplay>
                      {balance}
                    </StatDisplay>
                  </Stack.Item>

                  <Stack.Item>
                    <Box as="b" fontSize="1.6em">
                      Current Quirks
                    </Box>
                  </Stack.Item>

                  <Stack.Item grow width="100%">
                    <QuirkList
                      onClick={(quirkName, quirk) => {
                        if (getReasonToNotRemove(quirkName) !== undefined) {
                          return;
                        }

                        this.setState(oldState => {
                          return {
                            selectedQuirks: oldState.selectedQuirks
                              .filter(otherQuirk => quirkName !== otherQuirk),
                          };
                        });

                        act("remove_quirk", { quirk: quirk.name });
                      }}
                      quirks={quirks.filter(([quirkName, _]) => {
                        return this.state.selectedQuirks
                          .indexOf(quirkName) !== -1;
                      }).map(([quirkName, quirk]) => {
                        return [quirkName, {
                          ...quirk,
                          failTooltip: getReasonToNotRemove(quirkName),
                        }];
                      })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          );
        }}
      />
    );
  }
}
