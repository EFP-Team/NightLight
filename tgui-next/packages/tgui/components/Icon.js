import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = props => {
  const { name, size, className, style = {}, ...rest } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  const faRegular = FA_OUTLINE_REGEX.test(name);
  const faName = name.replace(FA_OUTLINE_REGEX, '');
  return (
    <Box
      as="i"
      className={classes([
        className,
        faRegular ? 'far' : 'fas',
        'fa-' + faName,
      ])}
      style={style}
      {...rest} />
  );
};

Icon.defaultHooks = pureComponentHooks;
