/* eslint-disable max-len */
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Input, Section, Box, Icon } from '../components';

let filterTerm;

const setFilterTerm = function (term) {
  filterTerm = term;
};

export const NtosRecords = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mode,
    records,
  } = data;

  return (
    <NtosWindow
      width={600}
      height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          NANOTRASEN PERSONNEL RECORDS (CLASSIFIED)
        </Section>
        <Section>
          <Input
            placeholder={"Filter results..."}
            fluid
            textAlign="center"
            // we're disabling no-return-assign because we're knowingly NOT using a comparator
            // eslint-disable-next-line no-return-assign
            onInput={(e, value) => setFilterTerm(value)}
          />
        </Section>
        {(mode==="security") && (
          records.map(record => (
            <Section hidden={!((record.name+" "+record.rank+" "+record.species+" "+record.gender+" "+record.age+" "+record.fingerprint).match(filterTerm)) && filterTerm} key={record.id}>
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Rank: {record.rank}<br />
              Species: {record.species}<br />
              Gender: {record.gender}<br />
              Age: {record.age}<br />
              Fingerprint Hash: {record.fingerprint}
              <br /><br />
              Criminal Status: {record.wanted ? record.wanted : "DELETED"}
            </Section>
          ))
        )}
        {(mode==="medical") && (
          records.map(record => (
            <Section hidden={!((record.name+" "+record.bloodtype+" "+record.m_stat+" "+record.p_stat).match(filterTerm)) && filterTerm} key={record.id}>
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Bloodtype: {record.bloodtype}<br />
              Minor Disabilities: {record.mi_dis}<br />
              Major Disabilities: {record.ma_dis}<br /><br />
              Notes: {record.notes}<br />
              Notes Contd: {record.cnotes}
            </Section>
          ))
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
