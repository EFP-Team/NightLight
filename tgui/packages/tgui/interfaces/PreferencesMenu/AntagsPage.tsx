import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Divider, Flex, Section, Stack, Tooltip } from "../../components";
import { Antagonist, Category } from "./antagonists/base";
import { PreferencesMenuData } from "./data";

const requireAntag = require.context("./antagonists/antagonists", false, /.ts$/);

const antagsByCategory = new Map<Category, Antagonist[]>();

// This will break at priorities higher than 10, but that almost definitely
// will not happen.
const binaryInsertAntag = binaryInsertWith((antag: Antagonist) => {
  return `${antag.priority}_${antag.name}`;
});

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag<{
    default?: Antagonist,
  }>(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(
      antagsByCategory.get(antag.category) || [],
      antag,
    )
  );
}

const AntagSelection = (props: {
  antagonists: Antagonist[],
  name: string,
}, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const className = "PreferencesMenu__Antags__antagSelection";

  const [predictedState, setPredictedState]
    = useLocalState(
      context,
      "AntagSelection_predictedState",
      new Set(data.selected_antags),
    );

  const enableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);

    act("set_antags", {
      antags,
      toggled: true,
    });
  };

  const disableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);

    act("set_antags", {
      antags,
      toggled: false,
    });
  };

  const antagonistKeys = props.antagonists.map(antagonist => antagonist.key);

  return (
    <Section title={props.name} buttons={(
      <>
        <Button
          color="good"
          onClick={() => enableAntags(antagonistKeys)}
        >
          Enable All
        </Button>

        <Button
          color="bad"
          onClick={() => disableAntags(antagonistKeys)}
        >
          Disable All
        </Button>
      </>
    )}>
      <Flex className={className} align="flex-end" wrap>
        {props.antagonists.map(antagonist => {
          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${
                  predictedState.has(antagonist.key) ? "on" : "off"
                }`,
              ])}
              key={antagonist.key}
            >
              <Stack align="center" vertical>
                <Stack.Item style={{
                  "font-weight": "bold",
                  "margin-top": "auto",
                  "max-width": "100px",
                  "text-align": "center",
                }}>
                  {antagonist.name}
                </Stack.Item>

                <Stack.Item align="center">
                  <Tooltip content={
                    <>
                      {antagonist.description.map((text, index) => {
                        return (
                          <div key={index}>
                            {text}
                            {
                              index !== antagonist.description.length - 1
                               && <Divider />
                            }
                          </div>
                        );
                      })}
                    </>
                  } position="bottom">
                    <Box
                      className={"antagonist-icon-parent"}
                      onClick={() => {
                        if (predictedState.has(antagonist.key)) {
                          disableAntags([antagonist.key]);
                        } else {
                          enableAntags([antagonist.key]);
                        }
                      }}
                    >
                      <Box className={classes([
                        "antagonists96x96",
                        antagonist.key,
                        "antagonist-icon",
                      ])} />
                    </Box>
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          );
        })}
      </Flex>
    </Section>
  );
};

export const AntagsPage = () => {
  return (
    <Box className="PreferencesMenu__Antags">
      <AntagSelection
        name="Roundstart"
        antagonists={antagsByCategory.get(Category.Roundstart)!}
      />

      <AntagSelection
        name="Midround"
        antagonists={antagsByCategory.get(Category.Midround)!}
      />

      <AntagSelection
        name="Latejoin"
        antagonists={antagsByCategory.get(Category.Latejoin)!}
      />
    </Box>
  );
};
