import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, LabeledList } from '../components';
import { Window } from '../layouts';
import { AccessConfig } from './common/AccessConfig';

type Data = {
  oneAccess: BooleanLike;
  regions: string[];
  accesses: string[];
};

export const CircuitAccessChecker = (props) => {
  const { act, data } = useBackend<Data>();
  const { oneAccess, regions = [], accesses = [] } = data;

  return (
    <Window width={420} height={360}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Access Required">
            <Button
              icon={oneAccess ? 'unlock' : 'lock'}
              content={oneAccess ? 'One' : 'All'}
              onClick={() => act('one_access')}
            />
          </LabeledList.Item>
        </LabeledList>
        <AccessConfig
          accesses={regions}
          selectedList={accesses}
          accessMod={(ref) =>
            act('set', {
              access: ref,
            })
          }
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) =>
            act('grant_region', {
              region: ref,
            })
          }
          denyDep={(ref) =>
            act('deny_region', {
              region: ref,
            })
          }
        />
      </Window.Content>
    </Window>
  );
};
