import { useBackend } from "../backend";
import { Box, Button, Section, Collapsible, Table } from "../components";
import { Window } from "../layouts";

export const Stack = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    amount,
    recipes,
  } = data;

  const height = Math.max(92 + Object.keys(recipes).length * 21.8, 250);

  return (
    <Window
      width={400}
      height={Math.min(height, 500)}
      resizable>
      <Window.Content scrollable>
        <Section title={"Amount: " + amount}>
          <RecipeList recipes={recipes} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const RecipeList = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    recipes,
  } = props;

  let sortedKeys = Object.keys(recipes).sort((a, b) => {
    if (a.toLowerCase() < b.toLowerCase()) {
      return -1;
    }
    if (a.toLowerCase() > b.toLowerCase()) {
      return 1;
    }
    return 0;
  });

  return sortedKeys.map(title => {
    let recipe = recipes[title];
    if (recipe.ref === undefined) {
      return (
        <Collapsible
          ml={1}
          mb={-0.8}
          color="label"
          title={title}>
          <Box ml={1}>
            <RecipeList recipes={recipe} />
          </Box>
        </Collapsible>
      );
    } else {
      return (
        <Recipe
          title={title}
          recipe={recipe} />
      );
    }
  });
};

const buildMultiplier = (recipe, amount) => {
  if (recipe.req_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.req_amount);
};

const Multipliers = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    recipe,
    maxMultiplier,
  } = props;

  let maxM = Math.min(maxMultiplier,
    Math.floor(recipe.max_res_amount / recipe.res_amount));

  let multipliers = [5, 10, 25];

  let finalResult = [];

  for (let multiplier of multipliers) {
    if (maxM >= multiplier) {
      finalResult.push((
        <Button
          content={multiplier * recipe.res_amount + "x"}
          onClick={() => act("make", {
            ref: recipe.ref,
            multiplier: multiplier,
          })} />
      ));
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push((
      <Button
        content={maxM * recipe.res_amount + "x"}
        onClick={() => act("make", {
          ref: recipe.ref,
          multiplier: maxM,
        })} />
    ));
  }

  return finalResult;
};

const Recipe = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    amount,
  } = data;

  const {
    recipe,
    title,
  } = props;

  const {
    res_amount,
    max_res_amount,
    req_amount,
    ref,
  } = recipe;

  let buttonName = title;
  buttonName += " (";
  buttonName += req_amount + " ";
  buttonName += ("sheet" + (req_amount > 1 ? "s" : ""));
  buttonName += ")";

  if (res_amount > 1) {
    buttonName = res_amount + "x " + buttonName;
  }

  let maxMultiplier = buildMultiplier(recipe, amount);

  return (
    <Box mb={0.3}>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Button
              fluid
              disabled={!maxMultiplier}
              icon="wrench"
              content={buttonName}
              onClick={() => act("make", {
                ref: recipe.ref,
                multiplier: 1,
              })} />
          </Table.Cell>
          {max_res_amount > 1 && maxMultiplier > 1 && (
            <Table.Cell collapsing>
              <Multipliers
                recipe={recipe}
                maxMultiplier={maxMultiplier} />
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
    </Box>
  );
};
