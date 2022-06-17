var difflet = require('../');
var subjectA = {
  levelOne: {
    levelTwo: {
      array: ['a', 'b', 3]
    }
  }
};

var subjectB = {
  levelOne: {
    levelTwo: {
      array: []
    }
  }
};

var s = difflet({ indent : 2, comment : true }).compare(
    subjectA,
    subjectB
);
process.stdout.write("DIFFLET:");
process.stdout.write(s);
