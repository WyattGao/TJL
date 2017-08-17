//
//  WearRecordDetailViewController.m
//  TangJiaoLian
//
//  Created by 高临原 on 2017/4/1.
//  Copyright © 2017年 高临原♬. All rights reserved.
//

#import "WearRecordDetailViewController.h"
#import "WearRecordDetailTableView.h"
#import "STDataAnalysisViewController.h"
#import "XueTangRecordView.h"

@interface WearRecordDetailViewController ()

@property (nonatomic,strong) WearRecordDetailTableView *mainTV;
@property (nonatomic,strong) NSMutableArray *bloodArr;

@end

@implementation WearRecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createData
{
    [self getSamGlucose];
    for (NSInteger i = 0;i < 5;i++) {
        [self getRecotdDataWithType:i];;
    }
    
}


/**
 获取佩戴期间血糖值
 */
- (void)getSamGlucose
{
    WS(ws);
    NSDictionary *postDic = @{
                              FUNCNAME : @"getSamGlucose",
                              INFIELD  : @{
                                      @"ACCOUNT" : USER_ACCOUNT,
                                      @"DEVICE"  : @"1",
                                      @"BEGINTIME" : _entity.starttime,
                                      @"ENDTIME" : _entity.endtime
                                      }
                              };
    [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
        if (GETTAG) {
            if (GETRETVAL) {
                _bloodArr = [NSMutableArray arrayWithArray:[[response objectForKey:@"Result"] objectForKey:@"OutTable"]];
                if (!_bloodArr.count) {
                    GL_ALERT_1(@"所选佩戴日期暂无血糖数据");
                } else {
                    [ws.mainTV.lishiZhiView reloadDataWithBloodArr:[[_bloodArr reverseObjectEnumerator] allObjects]];
                    ws.mainTV.lineView.lineColor.chartLine_Xarr     = [TimeManage XAllTimeAndStarTime:_entity.starttime andEndTime:[[_bloodArr lastObject] getStringValue:@"collectedtime"]];
                    ws.mainTV.lineView.lineColor.chartLine_PointArr = [NSMutableArray arrayWithArray:@[_bloodArr]];
                    [ws.mainTV.lineView wearRecordrefreshLineView];
                }
            }
        }
    } failure:^(GLRequest *request, NSError *error) {
        
    }];
}


/**
 获取记录信息
 */
- (void)getRecotdDataWithType:(GLRecordType)type{
    WS(ws);
    switch (type) {
        case GLRecordBloodType: //参比血糖
        {
            NSDictionary *postDic = @{
                                      @"FuncName":@"getSamReferGlucose",
                                      @"InField":@{
                                              @"ACCOUNT":USER_ACCOUNT,	//账号
                                              @"DEVICE":@"1",	//设备号
                                              @"BEGINTIME":_entity.starttime,	//开始时间
                                              @"ENDTIME":_entity.endtime,		//结束时间
                                              @"VERSION":GL_VERSION
                                              }
                                      };
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
                if (GETTAG) {
                    if (GETRETVAL) {
                        NSLog(@"获取参比%@",response);
                        ws.mainTV.lineView.lineColor.chartLine_bigPointArr = response[@"Result"][@"OutTable"];
                        [ws.mainTV.lineView wearRecordrefreshLineView];
                    }
                }
            } failure:^(GLRequest *request, NSError *error) {
                
            }];
        }
            break;
        case GLRecordFoodType:  //饮食
        {
            NSDictionary *postDic = @{
                                      @"FuncName":@"getBloodDiet",
                                      @"InField":@{
                                              @"ACCOUNT":USER_ACCOUNT,	//帐号
                                              @"YEAR":@"",	//年份
                                              @"MONTH":@"",		//月份
                                              //REPLACEADD
                                              @"BEGINDATE":_entity.starttime,	//开始日期，如果年和月份为空，则按开始日期和结束日期查询
                                              @"ENDDATE":_entity.endtime,	//结束日期
                                              @"DEVICE":@"1"
                                              },
                                      @"OutField":@[
                                              ]
                                      };
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
                if (GETTAG) {
                    if (GETRETVAL) {
                        NSLog(@"获取饮食%@",response);
                        ws.mainTV.lineView.lineColor.chartLine_oneFloorArr = response[@"Result"][@"OutTable"];
                        [ws.mainTV.lineView wearRecordrefreshLineView];
                    }
                }
            } failure:^(GLRequest *request, NSError *error) {
                
            }];
        }
            break;
        case GLRecordRrugs:     //用药
        {
            NSDictionary *postDic = @{
                                      @"FuncName":@"getBloodMedication",
                                      @"InField":@{
                                              @"ACCOUNT":USER_ACCOUNT,		//帐号
                                              @"YEAR":@"",	//年份
                                              @"MONTH":@"",		//月份
                                              @"TYPE":@"1",		//1普通用药,2胰岛素
                                              @"BEGINDATE":_entity.starttime,	//开始日期，如果年和月份为空，则按开始日期和结束日期查询
                                              @"ENDDATE":_entity.endtime,	//结束日期
                                              @"DEVICE":@"1"
                                              },
                                      @"OutField":@[
                                              ]
                                      };
            
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
                if (GETTAG) {
                    if (GETRETVAL) {
                        NSLog(@"获取用药%@",response);
                        ws.mainTV.lineView.lineColor.chartLine_threeFloorArr = response[@"Result"][@"OutTable"];
                        [ws.mainTV.lineView wearRecordrefreshLineView];
                    }
                }
            } failure:^(GLRequest *request, NSError *error) {
                
            }];
        }
            break;
        case GLRecordInsulin:   //胰岛素
        {
            NSDictionary *postDic = @{
                                      @"FuncName":@"getBloodMedication",
                                      @"InField":@{
                                              @"ACCOUNT":USER_ACCOUNT,		//帐号
                                              @"YEAR":@"",	//年份
                                              @"MONTH":@"",		//月份
                                              @"TYPE":@"2",		//1普通用药,2胰岛素
                                              @"BEGINDATE":_entity.starttime,	//开始日期，如果年和月份为空，则按开始日期和结束日期查询
                                              @"ENDDATE":_entity.endtime,	//结束日期
                                              @"DEVICE":@"1"
                                              },
                                      @"OutField":@[
                                              ]
                                      };
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
                if ( GETTAG) {
                    if (GETRETVAL) {
                        NSLog(@"获取胰岛素%@",response);
                        ws.mainTV.lineView.lineColor.chartLine_fourFloorArr = response[@"Result"][@"OutTable"];
                        [ws.mainTV.lineView wearRecordrefreshLineView];
                    }
                }
            } failure:^(GLRequest *request, NSError *error) {
                
            }];
        }
            break;
        case GLRecordSport: //运动
        {
            NSDictionary *postDic = @{
                                      @"FuncName":@"getBloodMotion",
                                      @"InField":@{
                                              @"ACCOUNT":USER_ACCOUNT,		//帐号
                                              @"YEAR":@"",	//年份
                                              @"MONTH":@"",		//月份
                                              @"BEGINDATE":_entity.starttime,	//开始日期，如果年和月份为空，则按开始日期和结束日期查询
                                              @"ENDDATE":_entity.endtime,	//结束日期
                                              @"DEVICE":@"1"
                                              },
                                      @"OutField":@[
                                              ]
                                      };
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
                if (GETTAG) {
                    if (GETRETVAL) {
                        NSLog(@"获取运动%@",response);
                        ws.mainTV.lineView.lineColor.chartLine_twoFloorArr = response[@"Result"][@"OutTable"];
                        [ws.mainTV.lineView wearRecordrefreshLineView];
                    }
                }
            } failure:^(GLRequest *request, NSError *error) {
                
            }];
        }
            break;
        default:
            break;
    }
}

- (void)createUI
{
    [self setLeftBtnImgNamed:nil];
    
    [self setNavTitle:[NSString stringWithFormat:@"%@ ~ %@",[[_entity.starttime toDate:@"yyyy-MM-dd HH:mm:ss"] toString:@"MM-dd"],[[_entity.endtime toDate:@"yyyy-MM-dd HH:mm:ss"] toString:@"MM-dd"]]];
    
    [self addSubView:self.mainTV];
    
    WS(ws);
    
    [self.mainTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.view).offset(64);
        make.bottom.equalTo(ws.view);
        make.left.equalTo(ws.view);
        make.right.equalTo(ws.view);
    }];
}

- (WearRecordDetailTableView *)mainTV
{
    if (!_mainTV) {
        _mainTV = [WearRecordDetailTableView new];
        WS(ws);
        [_mainTV tableViewDidSelect:^(NSIndexPath *indexPath) {
            switch (indexPath.row) {
                case 0:
                {
                    STDataAnalysisViewController *dataVC = [STDataAnalysisViewController new];
                    dataVC.startTimeStr = _entity.starttime;
                    dataVC.endTimeStr   = _entity.endtime;
                    [ws pushWithController:dataVC];
                }
                    break;
                case 1:
                    
                default:
                    break;
            }
        }];
    }
    return _mainTV;
}



@end