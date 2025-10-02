unit OldData;

interface

const
  oldmaxeventsingroup= 20;
  oldmaxcompetitions= 50;
  oldmaxrateplaces= 50;
  oldmaxevents= 50;
  oldmaxappresults= 30;
  oldmaxclassifications= 10;
  oldmaxgroups= 10;
  oldmaxseries= 10;
  oldmaxfinalshots= 20;

  oldeventstrlen= 35;
  oldeventabbrlen= 8;
  oldcompetitionstrlen= 30;
  oldpasswordstrlen= 20;
  oldclassificationstrlen= 10;
  oldprinterformattercodelen= 4;

type
  toldtime= record
    hour,minute,second: byte;
  end;
  tolddate= record
    year: word;
    month,day: byte;
  end;

  TOldEventStr= string [oldeventstrlen];
  TOldEventAbbr= string [oldeventabbrlen];
  TOldEvent= record
    name: toldeventstr;
    abbr: toldeventabbr;
  end;
  TOldCompetitionStr= string [oldcompetitionstrlen];
  tOldFilenameStr= string [12];
  TOldAccessLevel= (noaccess,readonly);
  TOldPassword= record
    password: array [0..oldpasswordstrlen] of byte;
    accesslevel: toldaccesslevel;
  end;
  TOldEventClassification= record
    result: word;
    classnumb: byte;
  end;
  TOldEventConfig= record
    mqsresult: word;
    realpart: boolean;
    finalplaces: word;
    groups,series: byte;
    sortwithlastserie: boolean;
    classifications: array [1..oldmaxclassifications] of toldeventclassification;
    listfilename: string [12];
    minratingresult: word;
  end;
  TOldClassificationsArray= array [0..oldmaxclassifications] of string [oldclassificationstrlen];
  TOldConfig= record
    filelabel: string [10];
    version: word;
    name: string [40];                    {}
    numberofcompetitions: byte;           {}
    numberofevents: byte;
    events: array [1..oldmaxevents] of toldevent;
    competitions: array [1..oldmaxcompetitions] of toldcompetitionstr;   {}
    groupsconfigfile: string [12];
    numsfile: string [12];
    tablefile: string [12];
    delmenupos: byte;                          {}
    warningbeeps: boolean;                     {}
    windowappearsteps: word;                   {}
    password: toldpassword;                         {}
    mqscompetitions: array [1..oldmaxcompetitions] of boolean;
    eventsconfig: array [1..oldmaxevents] of toldeventconfig;
    classifications: toldclassificationsarray;
    printercommandchar: string [2];
    currentprinter: string [20];
    currentprinterfile: string [8];
  end;

  toldappres= record
    result: word;
    rate: word;
  end;
  toldappresultsarray= array [1..oldmaxappresults] of toldappres;
  toldplacesforcompetition= array [1..oldmaxrateplaces] of word;
  toldratetableforevent= record
    places: array [1..oldmaxcompetitions] of toldplacesforcompetition;
    appresults: toldappresultsarray;
  end;
  toldtrunctimes= array [1..oldmaxcompetitions] of word;
  TOldFullTable= record
    events: array [1..oldmaxevents] of toldratetableforevent;
    trunctimes: toldtrunctimes;
  end;

  toldgroupeventsarray= array [1..oldmaxeventsingroup] of byte;
  toldgroupconfig= record
    groupname: string [40];                        {}
    datafile: toldfilenamestr;                        {}
    ratefile: toldfilenamestr;                        {}
    appfile: toldfilenamestr;                         {}
    appnfile: toldfilenamestr;                        {}
    listconffile: toldfilenamestr;                    {}
    ratescount: byte;
    events: toldgroupeventsarray;
    recalcdate: tolddate;                            {-}
    resultsavailable: boolean;
  end;

  toldmqsarray= array [1..oldmaxeventsingroup] of boolean;
  toldratesarray= array [1..oldmaxeventsingroup] of longint;
  toldperson= record
    number: longint;
    surname: string [18];        {} {s}
    name: string [14];           {}
    birthyear: word;             {} {s}
    birthday: string [5];
    country: string [15];        {} {s}
    countryabbr: string [3];
    town: string [15];
    qualification: byte;   {} {s}
    mqs: toldmqsarray;
    address: string [50];
    phone: string [40];
    passport: string [50];
    remarks: string [50];
    bestresults: array [1..oldmaxeventsingroup] of word;
    coaches: string [50];
    weapon: string [50];
    rates: toldratesarray;          {} {s}
    marked: byte;
  end;

  toldfinalresult= record
    int: word;
    tens: byte;
  end;
  toldratingrecord= record
    number: longint;
    date: tolddate;
    competition: toldcompetitionstr;
    compnum: byte;
    region: string [20];
    event: toldevent;
    eventnum: byte;
    place: word;
    mainresult: word;
    final: toldfinalresult;
    rate: longint;
  end;

implementation

end.

