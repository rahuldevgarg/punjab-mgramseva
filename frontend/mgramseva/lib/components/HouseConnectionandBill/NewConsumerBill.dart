
import 'package:flutter/material.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/routers/Routers.dart';
import 'package:mgramseva/utils/Constants/I18KeyConstants.dart';
import 'package:mgramseva/utils/Locilization/application_localizations.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/widgets/ButtonGroup.dart';
import 'package:mgramseva/widgets/ListLabelText.dart';
import 'package:mgramseva/widgets/ShortButton.dart';
import 'package:provider/provider.dart';

import '../../utils/models.dart';
import '../../widgets/CustomDetails.dart';

class NewConsumerBill extends StatefulWidget {
  final String? mode;
  final String? status;
  final WaterConnection? waterConnection;
  final List<Demands> demandList;

  const NewConsumerBill(this.mode, this.status, this.waterConnection, this.demandList);
  @override
  State<StatefulWidget> createState() {
    return NewConsumerBillState();
  }
}

class NewConsumerBillState extends State<NewConsumerBill> {
  @override
  void initState() {
    super.initState();
  }


  static getLabelText(label, value, context, {subLabel = ''}) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: (Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(right: 16),
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ApplicationLocalizations.of(context).translate(label),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.start,
                      ),
                      subLabel?.trim?.toString() != ''
                          ? Text( subLabel,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
                            color: Theme.of(context).primaryColorLight),
                      ) : Text('')
                    ])),
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,)
          ],
        )));
  }

  static getDueDatePenalty(dueDate, BuildContext context){
    late String localizationText;
    localizationText = '${ApplicationLocalizations.of(context).translate(i18.billDetails.CORE_PAID_AFTER)}';
    localizationText = localizationText.replaceFirst(
        '{dueDate}', dueDate);
    return localizationText;
  }

  @override
  Widget build(BuildContext context) {
    return buidBillview(widget.waterConnection?.fetchBill ?? BillList());
  }

  buidBillview(BillList billList) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    var penalty = billList.bill!.isEmpty ? Penalty(0.0, '0', false) : CommonProvider.getPenalty(widget.waterConnection?.demands);
    var penaltyApplicable = billList.bill!.isEmpty ? PenaltyApplicable(0.0)  : CommonProvider.getPenaltyApplicable(widget.demandList);
    var houseHoldProvider =
    Provider.of<HouseHoldProvider>(context, listen: false);

    return LayoutBuilder(builder: (context, constraints) {
      var houseHoldProvider =
          Provider.of<HouseHoldProvider>(context, listen: false);
      return billList.bill!.isEmpty
          ?
      Text("")
          :
      showBill(widget.demandList)
              ?
      houseHoldProvider.isfirstdemand == false &&
                      widget.mode != 'collect'
                  ? Text("")
                  : Column(
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: ListLabelText(i18
                                .billDetails.NEW_CONSUMERGENERATE_BILL_LABEL)),
                        Card(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible:
                                            houseHoldProvider.isfirstdemand ==
                                                    true
                                                ? true
                                                : false,
                                        child: TextButton.icon(
                                          onPressed: () => commonProvider
                                              .getFileFromPDFBillService(
                                                  {
                                                "Bill": [billList.bill?.first]
                                              },
                                                  {
                                                "key": widget.waterConnection
                                                            ?.connectionType ==
                                                        'Metered'
                                                    ? "ws-bill"
                                                    : "ws-bill-nm",
                                                "tenantId": commonProvider
                                                    .userDetails
                                                    ?.selectedtenant
                                                    ?.code,
                                              },
                                                  billList
                                                      .bill!.first.mobileNumber,
                                                  billList.bill?.first,
                                                  "Download"),
                                          icon: Icon(Icons.download_sharp),
                                          label: Text(
                                            ApplicationLocalizations.of(context)
                                                .translate(
                                                    i18.common.BILL_DOWNLOAD),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      houseHoldProvider.isfirstdemand == true
                                          ? getLabelText(
                                              i18.generateBillDetails
                                                  .LAST_BILL_GENERATION_DATE,
                                              DateFormats.timeStampToDate(
                                                      billList
                                                          .bill!.first.billDate,
                                                      format: "dd/MM/yyyy")
                                                  .toString(),
                                              context)
                                          : Text(""),
                                      if(CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, false) && !houseHoldProvider.isfirstdemand && widget.demandList.first.demandDetails?.any((e) => e.taxHeadMasterCode == '10201' ) == true )
                                        getLabelText(
                                            i18.billDetails.WS_10201,
                                            ('₹' + CommonProvider.getNormalPenalty(widget.demandList).toString()),
                                            context),
                                     if(!houseHoldProvider.isfirstdemand && (billList.bill?.first.totalAmount ?? 0) >= 0) getLabelText(
                                          houseHoldProvider.isfirstdemand ==
                                                  true
                                              ? i18.billDetails.CURRENT_BILL
                                              : i18.billDetails.ARRERS_DUES,
                                          ('₹' +
      (houseHoldProvider.isfirstdemand ?  widget.demandList.first.demandDetails!
                                                  .first.taxAmount : CommonProvider.getArrearsAmount(widget.demandList))
                                                  .toString()),
                                          context),
                                      if(houseHoldProvider.isfirstdemand) getLabelText(
                                          houseHoldProvider.isfirstdemand ==
                                              true
                                              ? i18.billDetails.CURRENT_BILL
                                              : i18.billDetails.ARRERS_DUES,
                                          ('₹' +
                                              (houseHoldProvider.isfirstdemand ?  widget.demandList.first.demandDetails!.first.taxHeadMasterCode == 'WS_TIME_PENALTY'
                                                  ? CommonProvider.getCurrentBill(widget.demandList)
                                              : CommonProvider.checkAdvance(widget.demandList) ? (widget.demandList.first.demandDetails!.first.taxAmount ?? 0)
                                              : ((widget.demandList.first.demandDetails!.first.taxAmount ?? 0) - (widget.demandList.first.demandDetails!.first.collectionAmount ?? 0)) : CommonProvider.getArrearsAmount(widget.demandList))
                                                  .toString()),
                                          context),
                                      if(houseHoldProvider.isfirstdemand == true)
                                          getLabelText(
                                              i18.billDetails.ARRERS_DUES,
                                              ( widget.demandList.first.demandDetails!.first.taxHeadMasterCode == 'WS_TIME_PENALTY'
                                                    ? '₹' + CommonProvider.getArrearsAmountOncePenaltyExpires(widget.demandList).toString() : '₹' + CommonProvider.getArrearsAmount(widget.demandList).toString()),
                                              context),
                                      getLabelText(
                                          !houseHoldProvider.isfirstdemand ? ((widget.waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0) >= 0 ? i18.generateBillDetails.PENDING_AMOUNT : i18.common.ADVANCE_AVAILABLE) : i18.billDetails.TOTAL_AMOUNT,
                                          ('₹' +
                                              (!houseHoldProvider.isfirstdemand ?
                                          (widget.waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0).abs() : widget.demandList.first.demandDetails!.first.taxHeadMasterCode == 'WS_TIME_PENALTY'
                                                  ? CommonProvider.getCurrentBill(widget.demandList) + CommonProvider.getArrearsAmountOncePenaltyExpires(widget.demandList)  : CommonProvider.getTotalBillAmount(widget.demandList)).toString()),
                                          context),
                                     if(CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, true) && houseHoldProvider.isfirstdemand) getLabelText(
                                          i18.common.CORE_ADVANCE_ADJUSTED,
                                          ((double.parse(CommonProvider.getAdvanceAdjustedAmount(widget.demandList)).abs() != 0.0
                                                  ? '- ₹' + (CommonProvider.getAdvanceAdjustedAmount(widget.demandList)).toString()
                                                  :  '₹' +(CommonProvider.getAdvanceAdjustedAmount(widget.demandList)).toString())),
                                          context),

                                      if(CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, false, true) && houseHoldProvider.isfirstdemand && penalty.isDueDateCrossed) getLabelText(
                                          i18.billDetails.CORE_PENALTY,
                                          ('₹' +
                                              penaltyApplicable.penaltyApplicable
                                                  .toString()),
                                          context),
                                      if(CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, true) && houseHoldProvider.isfirstdemand) getLabelText(
                                          i18.common.CORE_NET_DUE_AMOUNT,
                                          ('₹' +
                                              ( CommonProvider.getNetDueAmountWithWithOutPenalty(billList.bill?.first.totalAmount ?? 0, penalty))
                                                  .toString()),
                                          context),
                                      if(CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, false, true) && houseHoldProvider.isfirstdemand )  CustomDetailsCard(
                                          Column(
                                            children: [
                                              getLabelText(
                                                  i18.billDetails.CORE_PENALTY,
                                                  ('₹' +
                                                      (penalty.isDueDateCrossed ? penaltyApplicable.penaltyApplicable : penalty.penalty)
                                                          .toString()),
                                                  context,
                                                  subLabel: getDueDatePenalty(penalty.date, context)),
                                              getLabelText(
                                                  i18.billDetails.CORE_NET_DUE_AMOUNT_WITH_PENALTY,
                                                  ('₹' +
                                                      CommonProvider.getNetDueAmountWithWithOutPenalty(billList.bill?.first.totalAmount ?? 0, penalty, true)
                                                          .toString()),
                                                  context,
                                                  subLabel: getDueDatePenalty(penalty.date, context))

                                            ],
                                          )
                                      ),
                                      widget.mode == 'collect'
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: houseHoldProvider
                                                          .isfirstdemand ==
                                                      true
                                                  /*&&
                                             houseHoldProvider.waterConnection!
                                                      .connectionType !=
                                                  'Metered'*/
                                                  ? ButtonGroup(
                                                      i18.billDetails
                                                          .COLLECT_PAYMENT,
                                                      () =>
                                                          commonProvider
                                                              .getFileFromPDFBillService(
                                                                  {
                                                                "Bill": [
                                                                  billList.bill!
                                                                      .first
                                                                ]
                                                              },
                                                                  {
                                                                "key": widget
                                                                            .waterConnection
                                                                            ?.connectionType ==
                                                                        'Metered'
                                                                    ? 'ws-bill'
                                                                    : 'ws-bill-nm',
                                                                "tenantId": commonProvider
                                                                    .userDetails!
                                                                    .selectedtenant!
                                                                    .code,
                                                              },
                                                                  billList
                                                                      .bill!
                                                                      .first
                                                                      .mobileNumber,
                                                                  billList.bill!
                                                                      .first,
                                                                  "Share"),
                                                            CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, true)
                                                            && CommonProvider.checkAdvance(widget.demandList)
                                                            && ( CommonProvider.getNetDueAmountWithWithOutPenalty(billList.bill?.first.totalAmount ?? 0, penalty) == 0)
                                                            ? null
                                                                : () =>
                                                          onClickOfCollectPayment(
                                                              billList
                                                                  .bill!,
                                                              context))
                                                  : Visibility(
                                                visible: (billList.bill?.first.totalAmount ?? 0) > 0,
                                                    child: ShortButton(
                                                        i18.billDetails
                                                            .COLLECT_PAYMENT,
                                                  CommonProvider.getPenaltyOrAdvanceStatus(widget.waterConnection?.mdmsData, true)
                                                  && CommonProvider.checkAdvance(widget.demandList)
                                                  && CommonProvider.getAdvanceAmount(widget.demandList) == 0
                                                  && ( CommonProvider.getNetDueAmountWithWithOutPenalty(billList.bill?.first.totalAmount ?? 0, penalty) == 0)
                                                      ? null
                                                      : () =>
                                                            onClickOfCollectPayment(
                                                                billList
                                                                    .bill!,
                                                                context)),
                                                  ))
                                          : houseHoldProvider.isfirstdemand ==
                                                  true
                                              ? Container(
                                                  width: constraints.maxWidth >
                                                          760
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          1.12,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => commonProvider
                                                        .getFileFromPDFBillService(
                                                      {
                                                        "Bill": [
                                                          billList.bill!.first
                                                        ]
                                                      },
                                                      {
                                                        "key": widget
                                                                    .waterConnection
                                                                    ?.connectionType ==
                                                                'Metered'
                                                            ? 'ws-bill'
                                                            : 'ws-bill-nm',
                                                        "tenantId":
                                                            commonProvider
                                                                .userDetails!
                                                                .selectedtenant!
                                                                .code,
                                                      },
                                                      billList.bill!.first
                                                          .mobileNumber,
                                                      billList.bill!.first,
                                                      "Share",
                                                    ),
                                                    style: ButtonStyle(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          MaterialStateProperty
                                                              .all(EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          0)),
                                                      shape: MaterialStateProperty
                                                          .all(
                                                              RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 2,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                      )),
                                                    ),
                                                    icon: (Image.asset(
                                                        'assets/png/whats_app.png')),
                                                    label: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                          ApplicationLocalizations
                                                                  .of(context)
                                                              .translate(i18
                                                                  .common
                                                                  .SHARE_BILL),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16,
                                                          )),
                                                    ),
                                                  ),
                                                )
                                              : Text(""),
                                    ])))
                      ],
                    )
              : Text("");
    });
  }

  void onClickOfCollectPayment(List<Bill> bill, BuildContext context) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);

    Map<String, dynamic> query = {
      'consumerCode': bill.first.consumerCode,
      'businessService': bill.first.businessService,
      'tenantId': commonProvider.userDetails?.selectedtenant?.code,
      'demandList' : widget.demandList,
      'fetchBill' : bill,
      'status': widget.status
    };
    Navigator.pushNamed(context, Routes.HOUSEHOLD_DETAILS_COLLECT_PAYMENT,
        arguments: query);
  }

  bool showBill(List<Demands> demandList) {
    var index = -1;
    var houseHoldRegister = Provider.of<HouseHoldProvider>(context, listen: false);

    demandList = demandList.where((e) =>
    (!(e.isPaymentCompleted ?? false) && e.status != 'CANCELLED'))
        .toList();

    demandList = demandList.map((e) => Demands.fromJson(e.toJson())).toList();

    demandList.forEach((e) {
      e.demandDetails?.sort((a, b) => a
          .auditDetails!.createdTime!
          .compareTo(b.auditDetails!.createdTime!));
    });

    if(demandList.isEmpty){
      return false;
    }else if(!houseHoldRegister.isfirstdemand && widget.waterConnection?.connectionType != 'Metered'
        && (widget.waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0) == 0){
      return false;
    }else if(demandList.first.demandDetails?.last.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD'){
      return !houseHoldRegister.isfirstdemand;
    }else if((widget.waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0) > 0){
      return true;
    } else {

      if(demandList.isEmpty) return false;

      for (int i = 0; i < demandList.length; i++) {
        index = demandList[i].demandDetails?.lastIndexWhere((e) => e
            .taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ?? -1;

        if (index != -1) {
          var demandDetail = demandList[i].demandDetails?[index];
        if(demandDetail!.collectionAmount! == demandDetail.taxAmount!){
            if(demandList.first.demandDetails?.last.collectionAmount != 0){
              var list = <double>[];
              for(int j = 0; j <= i ; j++){
                for(int k = 0; k < (demandList[j].demandDetails?.length ?? 0); k++) {
                  if (k == index && j == i) break;
                  list.add(demandList[j].demandDetails![k].collectionAmount ?? 0);
                }
              }
              var collectedAmount = list.reduce((a, b) => a+b);
               return collectedAmount == demandDetail.collectionAmount?.abs();
            }
          }else if(demandDetail.taxAmount! < demandDetail.collectionAmount!){
          return true;
        }
        }
      }
    }
    return false;
  }

}
