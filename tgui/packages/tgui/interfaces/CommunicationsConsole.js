import { capitalize } from "common/string";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Input, Modal, Section, Table, TextArea } from "../components";
import { Window } from "../layouts";
import { logger } from "../logging";

const STATE_BUYING_SHUTTLE = "buying_shuttle";
const STATE_CHANGING_STATUS = "changing_status";
const STATE_MAIN = "main";
const STATE_MESSAGES = "messages";

// Used for whether or not you need to swipe to confirm an alert level change
const SWIPE_NEEDED = "SWIPE_NEEDED";

const AlertButton = (props, context) => {
  const { act, data } = useBackend(context);
  const thisIsCurrent = data.alertLevel === props.alertLevel;
  const { alertLevelTick, canSetAlertLevel } = data;

  return (<Button
    icon="exclamation-triangle"
    color={thisIsCurrent ? "good" : undefined}
    content={capitalize(props.alertLevel)}
    onClick={thisIsCurrent ? undefined : () => {
      if (canSetAlertLevel === SWIPE_NEEDED) {
        props.setShowAlertLevelConfirm([props.alertLevel, alertLevelTick]);
      } else {
        act("changeSecurityLevel", {
          newSecurityLevel: props.alertLevel,
        });
      }
    }}
  />);
};

const MessageModal = (props, context) => {
  const { act, data } = useBackend(context);
  const { maxMessageLength } = data;

  const [input, setInput] = useLocalState(context, props.label, "");

  const longEnough = props.minLength === undefined
    || input.length >= props.minLength;

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {props.label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height="20vh"
            width="80vw"
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setInput(value.substring(0, maxMessageLength));
            }}
            value={input}
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            icon={props.icon}
            content={props.buttonText}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? "You need a longer reason." : ""}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput("");
                props.onSubmit(input);
              }
            }}
          />

          <Button
            icon="times"
            content="Cancel"
            color="bad"
            onClick={props.onBack}
          />
        </Flex.Item>

        {
          props.notice
            ? <Flex.Item maxWidth="90vw">{props.notice}</Flex.Item>
            : null
        }
      </Flex>
    </Modal>
  );
};

const PageBuyingShuttle = (props, context) => {
  const { act, data } = useBackend(context);

  const buyableShuttles = [...data.shuttles];
  buyableShuttles.sort((a, b) => a.creditCost - b.creditCost);

  const shuttles = [];

  for (const shuttle of buyableShuttles) {
    shuttles.push((
      <Section
        title={(
          <span
            style={{
              display: "inline-block",
              width: "70%",
            }}>
            {shuttle.name}
          </span>
        )}
        key={shuttle.ref}
        buttons={(
          <Button
            content={`${shuttle.creditCost.toLocaleString()} credits`}
            disabled={data.budget < shuttle.creditCost}
            onClick={() => act("purchaseShuttle", {
              shuttle: shuttle.ref,
            })}
            tooltip={
              data.budget < shuttle.creditCost
                ? `You need ${(shuttle.creditCost - data.budget)} more credits.`
                : undefined
            }
            tooltipPosition="left"
          />
        )}>
        <Box>{shuttle.description}</Box>
        {
          shuttle.prerequisites
            ? <b>Prerequisites: {shuttle.prerequisites}</b>
            : null
        }
      </Section>
    ));
  }

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act("setState", { state: STATE_MAIN })}
        />
      </Section>

      <Section>
        Budget: <b>{data.budget.toLocaleString()}</b> credits
      </Section>

      {shuttles}
    </Box>
  );
};

const PageChangingStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { maxStatusLineLength } = data;

  const [lineOne, setLineOne] = useLocalState(context, "lineOne", data.lineOne);
  const [lineTwo, setLineTwo] = useLocalState(context, "lineTwo", data.lineTwo);

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act("setState", { state: STATE_MAIN })}
        />
      </Section>

      <Section>
        <Flex direction="column">
          <Flex.Item>
            <Button
              icon="times"
              content="Clear Alert"
              color="bad"
              onClick={() => act("setStatusPicture", { picture: "blank" })}
            />
          </Flex.Item>

          <Flex.Item mt={1}>
            <Button
              icon="check-square-o"
              content="Default"
              onClick={() => act("setStatusPicture", { picture: "default" })}
            />

            <Button
              icon="bell-o"
              content="Red Alert"
              onClick={() => act("setStatusPicture", { picture: "redalert" })}
            />

            <Button
              icon="exclamation-triangle"
              content="Lockdown"
              onClick={() => act("setStatusPicture", { picture: "lockdown" })}
            />

            <Button
              icon="exclamation-circle"
              content="Biohazard"
              onClick={() => act("setStatusPicture", { picture: "biohazard" })}
            />

            <Button
              icon="space-shuttle"
              content="Shuttle ETA"
              onClick={() => act("setStatusPicture", { picture: "shuttle" })}
            />
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="Message">
        <Flex direction="column">
          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineOne}
              width="200px"
              onChange={(_, value) => setLineOne(value)}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineTwo}
              width="200px"
              onChange={(_, value) => setLineTwo(value)}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              content="Message"
              onClick={() => act("setStatusMessage", {
                lineOne,
                lineTwo,
              })}
            />
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const PageMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alertLevel,
    alertLevelTick,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRequestNuke,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emagged,
    emergencyAccess,
    importantActionReady,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const children = [];
  const generalFunctions = [];

  const [callingShuttle, setCallingShuttle] = useLocalState(context, "calling_shuttle", false);
  const [messagingAssociates, setMessagingAssociates] = useLocalState(context, "messaging_assocaites", false);
  const [requestingNukeCodes, setRequestingNukeCodes] = useLocalState(context, "requesting_nuke_codes", false);

  const [
    [showAlertLevelConfirm, confirmingAlertLevelTick],
    setShowAlertLevelConfirm,
  ] = useLocalState(context, "showConfirmPrompt", [null, null]);

  if (canMakeAnnouncement) {
    generalFunctions.push(<Button
      icon="bullhorn"
      content="Make Priority Announcement"
      onClick={() => act("makePriorityAnnouncement")}
    />);
  }

  if (canToggleEmergencyAccess) {
    generalFunctions.push(<Button.Confirm
      icon="id-card-o"
      content={`${emergencyAccess ? "Disable" : "Enable"} Emergency Maintenance Access`}
      color={emergencyAccess ? "bad" : undefined}
      onClick={() => act("toggleEmergencyAccess")}
    />);
  }

  generalFunctions.push(<Button
    icon="desktop"
    content="Set Status Display"
    onClick={() => act("setState", { state: STATE_CHANGING_STATUS })}
  />);

  generalFunctions.push(<Button
    icon="envelope-o"
    content="Message List"
    onClick={() => act("setState", { state: STATE_MESSAGES })}
  />);

  let emergencyShuttleButton;

  if (shuttleCalled) {
    emergencyShuttleButton = (<Button.Confirm
      icon="space-shuttle"
      content="Recall Emergency Shuttle"
      color="bad"
      disabled={!shuttleRecallable}
      tooltip={shuttleRecallable ? undefined : "It's too late for the emergency shuttle to be recalled."}
      tooltipPosition="bottom-right"
      onClick={() => act("recallShuttle")}
    />);
  } else {
    emergencyShuttleButton = (<Button
      icon="space-shuttle"
      content="Call Emergency Shuttle"
      disabled={shuttleCanEvacOrFailReason !== 1}
      tooltip={
        shuttleCanEvacOrFailReason !== 1
          ? shuttleCanEvacOrFailReason
          : undefined
      }
      tooltipPosition="bottom-right"
      onClick={() => setCallingShuttle(true)}
    />);
  }

  if (canBuyShuttles !== 0) {
    generalFunctions.push(<Button
      icon="shopping-cart"
      content="Purchase Shuttle"
      disabled={canBuyShuttles !== 1}
      // canBuyShuttles is a string detailing the fail reason
      // if one can be given
      tooltip={canBuyShuttles !== 1 ? canBuyShuttles : undefined}
      tooltipPosition="right"
      onClick={() => act("setState", { state: STATE_BUYING_SHUTTLE })}
    />);
  }

  if (canMessageAssociates) {
    generalFunctions.push(<Button
      icon="comment-o"
      content={`Send message to ${emagged ? "[UNKNOWN]" : "CentCom"}`}
      disabled={!importantActionReady}
      onClick={() => setMessagingAssociates(true)}
    />);

    if (messagingAssociates) {
      children.push(<MessageModal
        label={`Message to transmit to ${emagged ? "[ABNORMAL ROUTING COORDINATES]" : "CentCom"} via quantum entanglement`}
        notice="Please be aware that this process is very expensive, and abuse will lead to...termination. Transmission does not guarantee a response."
        icon="comment-o"
        buttonText="Send"
        onBack={() => setMessagingAssociates(false)}
        onSubmit={message => {
          setMessagingAssociates(false);
          act("messageAssociates", {
            message,
          });
        }}
      />);
    }
  }

  if (canRequestNuke) {
    generalFunctions.push(<Button
      icon="bomb"
      content="Request Nuclear Authentication Codes"
      disabled={!importantActionReady}
      onClick={() => setRequestingNukeCodes(true)}
    />);

    if (requestingNukeCodes) {
      children.push(<MessageModal
        label="Reason for requesting nuclear self-destruct codes"
        notice="Misuse of the nuclear request system will not be tolerated under any circumstances. Transmission does not guarantee a response."
        icon="bomb"
        buttonText="Request Codes"
        onBack={() => setRequestingNukeCodes(false)}
        onSubmit={reason => {
          setRequestingNukeCodes(false);
          act("requestNukeCodes", {
            reason,
          });
        }}
      />);
    }
  }

  if (emagged) {
    generalFunctions.push(<Button
      icon="undo"
      content="Restore Backup Routing Data"
      onClick={() => act("restoreBackupRoutingData")}
    />);
  }

  if (callingShuttle) {
    children.push(<MessageModal
      label="Nature of emergency"
      icon="space-shuttle"
      buttonText="Call Shuttle"
      minLength={callShuttleReasonMinLength}
      onBack={() => setCallingShuttle(false)}
      onSubmit={reason => {
        setCallingShuttle(false);
        act("callShuttle", {
          reason,
        });
      }}
    />);
  }

  children.push(
    <Section title="Emergency Shuttle">
      {emergencyShuttleButton}

      {shuttleCalledPreviously
        ? (
          shuttleLastCalled
            ? (
              <Box>
                Most recent shuttle call/recall traced to:
                {" "}<b>{shuttleLastCalled}</b>
              </Box>
            )
            : <Box>Unable to trace most recent shuttle/recall signal.</Box>
        )
        : null}
    </Section>
  );

  if (canSetAlertLevel) {
    children.push(
      <Section title="Alert Level">
        <Flex justify="space-between">
          <Flex.Item>
            <Box>
              Currently on <b>{capitalize(alertLevel)}</b> Alert
            </Box>
          </Flex.Item>

          <Flex.Item>
            <AlertButton
              alertLevel="green"
              showAlertLevelConfirm={showAlertLevelConfirm}
              setShowAlertLevelConfirm={setShowAlertLevelConfirm}
            />

            <AlertButton
              alertLevel="blue"
              showAlertLevelConfirm={showAlertLevelConfirm}
              setShowAlertLevelConfirm={setShowAlertLevelConfirm}
            />
          </Flex.Item>
        </Flex>
      </Section>
    );

    if (showAlertLevelConfirm && confirmingAlertLevelTick === alertLevelTick) {
      children.push(
        <Modal>
          <Flex
            direction="column"
            textAlign="center"
            width="300px">
            <Flex.Item fontSize="16px" mb={2}>
              Swipe ID to confirm change
            </Flex.Item>

            <Flex.Item mr={2} mb={1}>
              <Button
                icon="id-card-o"
                content="Swipe ID"
                color="good"
                fontSize="16px"
                onClick={() => act("changeSecurityLevel", {
                  newSecurityLevel: showAlertLevelConfirm,
                })}
              />

              <Button
                icon="times"
                content="Cancel"
                color="bad"
                fontSize="16px"
                onClick={() => setShowAlertLevelConfirm(false)}
              />
            </Flex.Item>
          </Flex>
        </Modal>
      );
    }
  }

  children.push(
    <Section title="Functions">
      <Table>
        {generalFunctions.map((button, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              {button}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );

  return children;
};

const PageMessages = (props, context) => {
  const { act, data } = useBackend(context);
  const messages = data.messages || [];

  const children = [];

  children.push((
    <Section>
      <Button
        icon="chevron-left"
        content="Back"
        onClick={() => act("setState", { state: STATE_MAIN })}
      />
    </Section>
  ));

  const messageElements = [];

  for (const [messageIndex, message] of Object.entries(messages)) {
    let answers = null;

    if (message.possibleAnswers.length > 0) {
      answers = (
        <Box mt={1}>
          {message.possibleAnswers.map((answer, answerIndex) => (
            <Button
              content={answer}
              color={message.answered === answerIndex + 1 ? "good" : undefined}
              key={answerIndex}
              onClick={message.answered ? undefined : () => act("answerMessage", {
                message: messageIndex + 1,
                answer: answerIndex + 1,
              })}
            />
          ))}
        </Box>
      );
    }

    messageElements.push((
      <Section
        title={message.title}
        key={messageIndex}
        buttons={(
          <Button.Confirm
            icon="trash"
            content="Delete"
            color="red"
            onClick={() => act("deleteMessage", {
              message: messageIndex + 1,
            })}
          />
        )}>
        <Box>{message.content}</Box>

        {answers}
      </Section>
    ));
  }

  children.push(messageElements.reverse());

  return children;
};

export const CommunicationsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenticated,
    authorizeName,
    canLogOut,
    emagged,
    page,
  } = data;

  let pageComponent = null;

  if (authenticated) {
    switch (page) {
      case STATE_BUYING_SHUTTLE:
        pageComponent = <PageBuyingShuttle />;
        break;
      case STATE_CHANGING_STATUS:
        pageComponent = <PageChangingStatus />;
        break;
      case STATE_MAIN:
        pageComponent = <PageMain />;
        break;
      case STATE_MESSAGES:
        pageComponent = <PageMessages />;
        break;
      default:
        pageComponent = <Box>Page not implemented: {page}</Box>;
    }
  }

  return (
    <Window
      height={500}
      theme={emagged ? "syndicate" : undefined}
      resizable>
      <Window.Content scrollable>
        {(canLogOut || !authenticated)
          ? (
            <Section title="Authentication">
              <Button
                icon={authenticated ? "sign-out-alt" : "sign-in-alt"}
                content={authenticated ? `Log Out${authorizeName ? ` (${authorizeName})` : ""}` : "Log In"}
                color={authenticated ? "bad" : "good"}
                onClick={() => act("toggleAuthentication")}
              />
            </Section>
          )
          : null}

        {pageComponent}
      </Window.Content>
    </Window>
  );
};
