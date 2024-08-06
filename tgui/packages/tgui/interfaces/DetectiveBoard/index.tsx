import { useEffect, useState } from 'react';

import { useBackend } from '../../backend';
import { Box, Button, Icon, Stack } from '../../components';
import { Window } from '../../layouts';
import { Connection, Connections, Position } from '../common/Connections';
import { BoardTabs } from './BoardTabs';
import { DataCase, DataEvidence } from './DataTypes';
import { Evidence } from './Evidence';

type Data = {
  cases: DataCase[];
  current_case: number;
  data_connections: Connection[];
};

const PIN_Y_OFFSET = -30;

export function DetectiveBoard(props) {
  const { act, data } = useBackend<Data>();
  const { cases, current_case, data_connections } = data;

  const [connectingEvidence, setConnectingEvidence] =
    useState<DataEvidence | null>(null);
  const [connection, setConnection] = useState<Connection | null>(null);
  const [connections, setConnections] =
    useState<Connection[]>(data_connections);

  function handlePinStartConnecting(
    evidence: DataEvidence,
    mousePos: Position,
  ) {
    setConnectingEvidence(evidence);
    setConnection({
      color: 'red',
      from: getPinPosition(evidence),
      to: mousePos,
    });
  }

  function getPinPosition(evidence: DataEvidence) {
    return { x: evidence.x + 15, y: evidence.y + 45 };
  }

  function handlePinConnected(evidence: DataEvidence) {
    setConnection(null);
    setConnectingEvidence(null);
  }

  useEffect(() => {
    if (!connectingEvidence) {
      return () => window.removeEventListener('mousemove', handleMouseMove);
    }

    function handleMouseMove(args: MouseEvent) {
      if (connectingEvidence) {
        setConnection({
          color: 'red',
          from: getPinPosition(connectingEvidence),
          to: { x: args.clientX, y: args.clientY + PIN_Y_OFFSET },
        });
      }
    }

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, [connectingEvidence]);

  function handleMouseUpOnPin(evidence: DataEvidence, args) {
    if (
      connectingEvidence &&
      connectingEvidence.ref !== evidence.ref &&
      !connectingEvidence.connections.includes(evidence.ref) &&
      !evidence.connections.includes(connectingEvidence.ref)
    ) {
      setConnections([
        ...connections,
        {
          color: 'red',
          from: getPinPosition(connectingEvidence),
          to: getPinPosition(evidence),
        },
      ]);
      act('add_connection', {
        from_ref: connectingEvidence.ref,
        to_ref: evidence.ref,
      });
      setConnection(null);
      setConnectingEvidence(null);
    }
  }

  return (
    <Window width={1200} height={800}>
      <Window.Content>
        {cases.length > 0 ? (
          <>
            {connection ? (
              <Connections
                lineWidth={5}
                connections={[...connections, connection]}
                zLayer={99}
              />
            ) : (
              <Connections
                lineWidth={5}
                connections={connections}
                zLayer={99}
              />
            )}
            <BoardTabs />
            {cases?.map(
              (item, i) =>
                current_case - 1 === i && (
                  <Box key={'case' + i} className="Board__Content">
                    {item?.evidences?.map((evidence, index) => (
                      <Evidence
                        key={'evidence' + index}
                        evidence={evidence}
                        case_ref={item.ref}
                        act={act}
                        onPinStartConnecting={handlePinStartConnecting}
                        onPinConnected={handlePinConnected}
                        onPinMouseUp={handleMouseUpOnPin}
                      />
                    ))}
                  </Box>
                ),
            )}
          </>
        ) : (
          <Stack fill>
            <Stack.Item grow>
              <Stack fill vertical>
                <Stack.Item grow />
                <Stack.Item align="center" grow={2}>
                  <Icon color="average" name="search" size={15} />
                </Stack.Item>
                <Stack.Item align="center">
                  <Box color="red" fontSize="18px" bold mt={5}>
                    You have no cases! Create the first one
                  </Box>
                </Stack.Item>
                <Stack.Item align="center" grow={3}>
                  <Button
                    icon="plus"
                    content="Create case"
                    onClick={() => act('add_case')}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
}
