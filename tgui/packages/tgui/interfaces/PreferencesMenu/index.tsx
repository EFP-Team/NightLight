import { exhaustiveCheck } from "common/exhaustive";
import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";
import { Window } from "../../layouts";
import { CharacterProfile, PreferencesMenuData } from "./data";
import { AntagsPage } from "./AntagsPage";
import { GamePreferencesPage } from "./GamePreferencesPage";
import { JobsPage } from "./JobsPage";
import { MainPage } from "./MainPage";
import { SpeciesPage } from "./SpeciesPage";

enum Page {
  Antags,
  Game,
  Jobs,
  Main,
  Species,
}

const CHARACTER_PREFERENCE_PAGES = new Set([
  Page.Antags,
  Page.Jobs,
  Page.Main,
  Page.Species,
]);

const CharacterProfiles = (props: {
  activeName: string,
  onClick: (index: number) => void,
  profiles: (CharacterProfile | null)[],
}) => {
  const { profiles } = props;

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, slot) => (
        <Stack.Item key={slot}>
          <Button
            selected={profile?.name === props.activeName}
            onClick={() => {
              props.onClick(slot);
            }} fluid>{profile ? profile.name : "New Character"}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const PreferencesMenu = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const [currentPage, setCurrentPage] = useLocalState(context, "currentPage", Page.Main);

  let page;

  switch (currentPage) {
    case Page.Antags:
      page = <AntagsPage />;
      break;
    case Page.Game:
      page = <GamePreferencesPage />;
      break;
    case Page.Jobs:
      page = <JobsPage />;
      break;
    case Page.Main:
      page = <MainPage openSpecies={() => setCurrentPage(Page.Species)} />;
      break;
    case Page.Species:
      page = <SpeciesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window title="Character Preferences" width={920} height={770} scrollable>
      <Window.Content>
        <Stack vertical fill>
          {CHARACTER_PREFERENCE_PAGES.has(currentPage) && (
            <>
              <Stack.Item>
                <CharacterProfiles
                  activeName={data.active_name}
                  onClick={(slot) => {
                    act("change_slot", {
                      slot: slot + 1,
                    });
                  }} profiles={data.character_profiles} />
              </Stack.Item>
              <Stack.Divider />
            </>
          )}

          <Stack.Item>
            {page}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
