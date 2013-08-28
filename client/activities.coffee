@definitions = {
  'plusesDeltas': {
    title: 'Pluses and Deltas',
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Pluses',type:1, spawnable: true},
      {title:'Deltas', type:2, spawnable: true}]
  },
  'plusesDeltasKudos': {
    title: 'Pluses, Deltas, Kudos',
    template: 'votableColumns',
    columnClass: 'span4',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Pluses',type:1, spawnable: true},
      {title:'Deltas', type:2, spawnable: true},
      {title:'Kudos', type:3, spawnable: true}]
  },
  'madsSadsGlads': {
    title: 'Glads, Sads, Mads',
    template: 'votableColumns',
    columnClass: 'span4',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Glads',type:1, spawnable: true},
      {title:'Sads', type:2, spawnable: true},
      {title:'Mads', type:3, spawnable: true}]
  },
  'startStopContinue': {
    title: 'Start, Stop, Continue',
    template: 'votableColumns',
    columnClass: 'span4',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Start Doing',type:1, spawnable: true},
      {title:'Stop Doing', type:2, spawnable: true},
      {title:'Continue Doing', type:3, spawnable: true}]
  },
  'fiveWhys': {
    title: 'Five Whys',
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: false,
    columns: [
      {title:'Why, Why, Why?', type:1, spawnable: false}]
  },
  'rootCause': {
    title: 'Root Cause Analysis'
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Root Cause Analysis', type:1, spawnable: false},
      {title:'Action Items', type:2, claimable: true, spawnable: false}]
  }
  'fourLs': {
    title: "The Four L's",
    template: 'votableColumns',
    columnClass: 'span3',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Liked',type:1, spawnable: true},
      {title:'Learned', type:2, spawnable: true},
      {title:'Lacked', type:3, spawnable: true},
      {title:'Longed For', type:4, spawnable: true}]
  },
  'sailboat': {
    title: 'Sailboat',
    template: 'votableColumns',
    columnClass: 'span6',
    hasVotableColumn: true,
    votesEach: 3,
    columns: [
      {title:'Anchors',type:1, spawnable: true},
      {title:'Wind', type:2, spawnable: true}]
  }
}