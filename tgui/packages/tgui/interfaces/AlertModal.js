import { useBackend } from '../backend';
import { Button, Flex, Box } from '../components';
import { Window } from '../layouts';

export const AlertModal = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    message,
    buttons,
  } = data;

  return (
    <Window
      title={title}
      width={350}
      height={150}
      resizable>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item grow={1}>
            <Flex
              direction="column"
              className="AlertModal__Message"
              height="100%">
              <Flex.Item>
                <Box m={1}>
                  {message}
                </Box>
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item my={2}>
            <Flex className="AlertModal__Buttons">
              {buttons.map(button => (
                <Flex.Item key={button} mx={1}>
                  <Button
                    px={3}
                    onClick={() => act("choose", { choice: button })}>
                    {button}
                  </Button>
                </Flex.Item>
              ))}
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
