unit Const_SearchOptionUnit;

interface
const
  STAGE_SEQ_NUM = 5;
  STAGE_NAME_LIST: array[0..6] of String = (
                            'pumping',
                            'Heatup',
                            'Growth',
                            'Stabilization',
                            'Linear Decreasing',
                            'Decreasing',
                            'Cooling'
                            );
  SOP_NAME_SEQ: array[0..6] of String = (
                            'table',
                            'columns',
                            'group',
                            'round',
                            'datetime',
                            'stage',
                            'stage_auto'
                            );
  SOP_ITEM_SEQ: array[0..17] of String = (
                            'table.name',
                            'columns.datetime',
                            'datetime.split',
                            'columns.normal',
                            'columns.group',
                            'group.use',
                            'group.timeunit',
                            'group.func',
                            'round.use',
                            'round.decplace',
                            'stage.use',
                            'stage.start',
                            'stage.end',
                            'stage_auto.use',
                            'stage_auto.stagenum',
                            'stage_auto.tablename',
                            'stage_auto.stagecol',
                            'stage_auto.datecol'
                            );

  {
			0 = table_name
			1 = datetime_column
			2 = datetime_split
			3 = columns
			4 = columns.group
			5 = group.use
			6 = group.several
			7 = group.func
			8 = round.use
			9 = round.decplace
			10 = stage.use
			11 = stage.start
			12 = stage.end
      13 = stage_log.use
			14 = stage_log.num
			15 = stage_log.name
			16 = stage_log.stagecol
			17 = stage_log.date
  }



  DATETIME_COLUMN_PATTERN: array[0..2] of String = ( 'date', 'time', 'stage' );
  EVENT_LOG_TABLE: array[0..3] of String = ( 'journal', 'currstate', 'eventlog', 'alarmlog' );

  ITEM_LIST_GROUP_TIMEUNIT_VIEW: array[0..21] of String = (
                        '5 sec', '10 sec', '15 sec', '20 sec', '30 sec', //5
                        '1 min', '2 min', '3 min', '4 min', '5 min', '6 min', '10 min', '15 min', '20 min', '30 min', //10
                        '1 hour', '2 hour', '3 hour', '4 hour', '6 hour', '8 hour', '12 hour' //7
                        );
  ITEM_LIST_GROUP_TIMEUNIT_FACT: array[0..21] of Integer = (
                        5, 10, 15, 20, 30,
                        100, 200, 300, 400, 500, 600, 1000, 1500, 2000, 3000,
                        10000, 20000, 30000, 40000, 60000, 80000, 100000
                        );
  ITEM_LIST_GROUP_FUNCTION: array[0..2] of String = (
                        'AVG', 'MIN', 'MAX'
                        );
  ITEM_DEFAULT_GROUP_TIMEUNIT = '1 min';
  ITEM_DEFAULT_GROUP_FUNCTION = 'AVG';
  ITEM_LIST_ROUND_DECPLACE_MIN = 0;
  ITEM_LIST_ROUND_DECPLACE_MAX = 7;
  ITEM_LIST_ROUND_DECPLACE_DEF = ITEM_LIST_ROUND_DECPLACE_MAX;

  ITEM_LIST_AUTO_STAGE_SEQ: array[0..4] of Integer = (
                        1, //heating
                        2, //growth
                        3, //Stabilization
                        4, //Linear Decreasing
                        5  //Decreasing
                        );
implementation

end.
