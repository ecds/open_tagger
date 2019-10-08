import { helper } from '@ember/component/helper';

export function isinstanceof(params/*, hash*/) {
  // console.log(params[0] instanceof Object)
  if (params[1] == 'Object') {
    return params[0] instanceof Object
  } else if (params[1] == 'Array') {
    return params[0] instanceof Array
  }
  return false;
}

export default helper(isinstanceof);
