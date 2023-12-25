import { multiline } from 'common/string';

import { Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const OperativeMidround: Antagonist = {
  key: 'operativemidround',
  name: 'Nuclear Assailant',
  description: [
    multiline`
      A form of nuclear operative that is offered to ghosts in the middle
      of the shift.
    `,
    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default OperativeMidround;
