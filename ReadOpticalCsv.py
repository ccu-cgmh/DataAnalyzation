import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('Label', type=str, help="標籤")
args = vars(parser.parse_args())

print(args['Label'])
LabelList = ['LFHD','','','RFHD','','','LBHD','','','RBHD','','','C7','','','T10','','','CLAV','','','STRN','','','RBAK','','','LSHO','','',\
'LELB','','','LWRA','','','LWRB','','','LFIN','','','RSHO','','','RELB','','','RWRA','','','RWRB','','','RFIN','','','LASI','','',\
'RASI','','','LPSI','','','RPSI','','','LTHI','','','LKNE','','','LTIB','','','LANK','','','LHEE','','','LTOE','','','RTHI','','',\
'RKNE','','','RTIB','','','RANK','','','RHEE','','','RTOE','','','CentreOfMass','','','CentreOfMassFloor','','','LHipAngles','','',\
'LKneeAngles','','','LAnkleAngles','','','LAbsAnkleAngle','','','RHipAngles','','','RKneeAngles','','','RAnkleAngles','','',\
'RAbsAnkleAngle','','','LShoulderAngles','','','LElbowAngles','','','LWristAngles','','','RShoulderAngles','','','RElbowAngles','','',\
'RWristAngles','','','LNeckAngles','','','RNeckAngles','','','LSpineAngles','','','RSpineAngles','','','LHeadAngles','','',\
'RHeadAngles','','','LThoraxAngles','','','RThoraxAngles','','','LPelvisAngles','','','RPelvisAngles','','','LFootProgressAngles','','',\
'RFootProgressAngles','','','LGroundReactionForce','','','RGroundReactionForce','','','LNormalisedGRF','','','RNormalisedGRF','','',\
'LAnkleForce','','','RAnkleForce','','','LKneeForce','','','RKneeForce','','','LHipForce','','','RHipForce','','','LWaistForce','','',\
'RWaistForce','','','LNeckForce','','','RNeckForce','','','LShoulderForce','','','RShoulderForce','','','LElbowForce','','',\
'RElbowForce','','','LWristForce','','','RWristForce','','','LGroundReactionMoment','','','RGroundReactionMoment','','',\
'LAnkleMoment','','','RAnkleMoment','','','LKneeMoment','','','RKneeMoment','','','LHipMoment','','','RHipMoment','','',\
'LWaistMoment','','','RWaistMoment','','','LNeckMoment','','','RNeckMoment','','','LShoulderMoment','','','RShoulderMoment','','',\
'LElbowMoment','','','RElbowMoment','','','LWristMoment','','','RWristMoment','','','LAnklePower','','','RAnklePower','','',\
'LKneePower','','','RKneePower','','','LHipPower','','','RHipPower','','','LWaistPower','','','RWaistPower','','','LNeckPower','','',\
'RNeckPower','','','LShoulderPower','','','RShoulderPower','','','LElbowPower','','','RElbowPower','','','LWristPower','','',\
'RWristPower','','','HEDO','','','HEDP','','','HEDL','','','HEDA','','','LCLO','','','LCLP','','','LCLL','','','LCLA','','',\
'LFEO','','','LFEP','','','LFEL','','','LFEA','','','LFOO','','','LFOP','','','LFOL','','','LFOA','','','LHNO','','','LHNP','','',\
'LHNL','','','LHNA','','','LHUO','','','LHUP','','','LHUL','','','LHUA','','','LRAO','','','LRAP','','','LRAL','','','LRAA','','',\
'LTIO','','','LTIP','','','LTIL','','','LTIA','','','LTOO','','','LTOP','','','LTOL','','','LTOA','','','PELO','','','PELP','','',\
'PELL','','','PELA','','','RCLO','','','RCLP','','','RCLL','','','RCLA','','','RFEO','','','RFEP','','','RFEL','','','RFEA','','',\
'RFOO','','','RFOP','','','RFOL','','','RFOA','','','RHNO','','','RHNP','','','RHNL','','','RHNA','','','RHUO','','','RHUP','','',\
'RHUL','','','RHUA','','','RRAO','','','RRAP','','','RRAL','','','RRAA','','','RTIO','','','RTIP','','','RTIL','','','RTIA','','',\
'RTOO','','','RTOP','','','RTOL','','','RTOA','','','TRXO','','','TRXP','','','TRXL','','','TRXA'	]
	
'''
print(args['Label'])
LabelList = ['LFHD','','','RFHD','','','LBHD','','','RBHD','','','C7','','','T10','','','CLAV','','','STRN','','','RBAK','','','LSHO','','',\
'LELB','','','LWRA','','','LWRB','','','LFIN','','','RSHO','','','RELB','','','RWRA','','','RWRB','','','RFIN','','','LASI','','',\
'RASI','','','LPSI','','','RPSI','','','CentreOfMass','','','CentreOfMassFloor','','','LShoulderAngles','','','LElbowAngles','','',\
'LWristAngles','','','RShoulderAngles','','','RElbowAngles','','','RWristAngles','','','LNeckAngles','','','RNeckAngles','','',\
'LSpineAngles','','','RSpineAngles','','','LHeadAngles','','','RHeadAngles','','','LThoraxAngles','','','RThoraxAngles','','',\
'LPelvisAngles','','','RPelvisAngles','','','LShoulderForce','','','RShoulderForce','','','LElbowForce','','','RElbowForce','','',\
'LWristForce','','','RWristForce','','','LShoulderMoment','','','RShoulderMoment','','','LElbowMoment','','','RElbowMoment','','',\
'LWristMoment','','','RWristMoment','','','LShoulderPower','','','RShoulderPower','','','LElbowPower','','','RElbowPower','','',\
'LWristPower','','','RWristPower','','','HEDO','','','HEDP','','','HEDL','','','HEDA','','','LCLO','','','LCLP','','','LCLL','','',\
'LCLA','','','LHNO','','','LHNP','','','LHNL','','','LHNA','','','LHUO','','','LHUP','','','LHUL','','','LHUA','','','LRAO','','',\
'LRAP','','','LRAL','','','LRAA','','','PELO','','','PELP','','','PELL','','','PELA','','','RCLO','','','RCLP','','','RCLL','','',\
'RCLA','','','RHNO','','','RHNP','','','RHNL','','','RHNA','','','RHUO','','','RHUP','','','RHUL','','','RHUA','','','RRAO','','',\
'RRAP','','','RRAL','','','RRAA','','','TRXO','','','TRXP','','','TRXL','','','TRXA']
'''
print(LabelList.index(args['Label']))
LabelIndex = LabelList.index(args['Label']) + 1
mypath = 'OpticalInput'
for file in os.listdir(mypath):
    print(file)
    records = []
    with open('OpticalInput/'+file, 'r') as f:
        #next(f) # 跳過第一行
        doc = f.readlines()
    for line in doc:
        items = line.split(',')
        new_record = {}
        for index, item in enumerate(items):
            try:
                new_record[index] = str(item.strip('\n')) # 去掉換行
            except:
                print('字串轉為資料時發生錯誤, 請檢查資料是否有誤')
                print('原始資料: '+line)
            else:
                pass
        records.append(new_record)
    t = 0
    with open('OpticalOutput/'+args['Label']+'_'+file, 'w') as f:
        for record in records:
            if len(record) >= 308:
                if t < 2:
                    t = t + 1
                    continue
                for i in range(len(record))[LabelIndex:LabelIndex+3]:
                    f.write(str(record[i])+',')
                    #f.write(str(i)+',')
                f.write('\n')
        
print('檔案處理完成: '+file)