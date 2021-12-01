import { useBackend, useSharedState } from '../backend';
import { clamp01 } from 'common/math';
import { KEY_ENTER } from 'common/keycodes';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type TextboxData = {
  max_length: number;
  message: string;
  placeholder: string;
  timeout: number;
  title: string;
};

type Validator = {
  isValid: boolean;
  error: string | null;
};

export const TextboxModal = (_, context) => {
  const { data } = useBackend<TextboxData>(context);
  const { max_length, message, placeholder, timeout, title } = data;
  const [input, setInput] = useSharedState(context, 'input', placeholder);
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: false, error: null }
  );
  const onChangeHandler = (event) => {
    event.preventDefault();
    const target = event.target;
    setInputIsValid(validateInput(target.value, max_length));
    setInput(target.value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight = 130 + Math.ceil(message.length / 5);

  return (
    <Window title={title} width={450} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <MessageBox />
          </Stack.Item>
          <Stack.Item>
            <InputArea
              input={input}
              inputIsValid={inputIsValid}
              onChangeHandler={onChangeHandler}
            />
          </Stack.Item>
          <Stack.Item>
            <ButtonGroup input={input} inputIsValid={inputIsValid} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Timed text input windows!
 * Why? I don't know!
 */
const Loader = (props) => {
  const { value } = props;

  return (
    <div className="AlertModal__Loader">
      <Box
        className="AlertModal__LoaderProgress"
        style={{ width: clamp01(value) * 100 + '%' }}
      />
    </div>
  );
};

/** The message displayed. Scales the window height. */
const MessageBox = (_, context) => {
  const { data } = useBackend<TextboxData>(context);
  const { message } = data;
  return (
    <Section fill>
      <Box color="label">{message}</Box>
    </Section>
  );
};

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props, context) => {
  const { act } = useBackend<TextboxData>(context);
  const { input, inputIsValid, onChangeHandler } = props;

  return (
    <Input
      fluid
      onInput={(event) => onChangeHandler(event)}
      onKeyDown={(event) => {
        const keyCode = window.event ? event.which : event.keyCode;
        /**
         * Simulate a click when pressing space or enter,
         * allow keyboard navigation, override tab behavior
         */
        if (keyCode === KEY_ENTER && inputIsValid) {
          act('choose', { entry: input });
        }
      }}
      placeholder="Type something..."
      value={input}
    />
  );
};

/** The buttons shown at bottom. Will display the error
 * if the input is invalid.
 */
const ButtonGroup = (props, context) => {
  const { act } = useBackend<TextboxData>(context);
  const { input, inputIsValid } = props;
  const { isValid, error } = inputIsValid;

  return (
    <Stack fill>
      <Stack.Item>
        <Button
          color="good"
          disabled={!isValid}
          onClick={() => act('submit', { entry: input })}>
          Submit
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        {!isValid && <Box color="average">{error}</Box>}
      </Stack.Item>
      <Stack.Item>
        <Button color="bad" onClick={() => act('cancel')}>
          Cancel
        </Button>
      </Stack.Item>
    </Stack>
  );
};

/** Helper functions */
const validateInput = (input, max_length) => {
  if (!!max_length && input.length > max_length) {
    return { isValid: false, error: `Too many characters!` };
  } else if (input.length === 0) {
    return { isValid: false, error: null };
  }
  return { isValid: true, error: null };
};
