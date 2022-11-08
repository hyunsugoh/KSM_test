<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script>
	var subPjtId = parent.subPjtId; //parent에서 subPjtId 추출.
	var modelUid = "${modelUid}";
	var mid = "${mid}";
	var sourceIds = parent.sourceidStr;
	
	$(document).ready(function() {
		var sourceIdArr = sourceIds.split("|");
		var sourceId = cfn_getSourceIDInPredict(sourceIdArr);
		var modelId = cfn_getModelIDInPredict(sourceIdArr);
		cfn_setSourceListBox(sourceId);
		
		var param = {
			subpjtid  : subPjtId,
			modeluid  : modelUid,
			sourceuid : sourceId,
			modelid   : modelId,
			gubun	  : "PR"
		};
		$.doPost({
			url : "/mliframe/getControlInfo.do",
			data : param,
			success : function(data){
				console.log(data);
				cfn_setDataGrid(subPjtId,modelUid,sourceId,data.params);
				//cfn_createFeatureGrid(data.fcols,{disabled:true});
				cfn_createLabelGrid(data.lcols,{disabled:true});
			},
			error : function(jqxXHR, textStatus, errorThrown){
				alert('오류가 발생 했습니다.');
			}
		});
		
		$('#dataSubmitBtn').click(function(e){
			
			var controlParam = cfn_getControlParamML();
			
			if($("#select_source").length > 0) {
				sourceId = $("#select_source").val();
			}
			
			var predictParam = {
					subpjtid	: subPjtId,
					sourceid	: sourceId,
					modelid 	: modelId,
					targetid	: modelUid,
					
					//features 	: controlParam.fcols,
					label	 	: controlParam.lcols[0],
					
					algparam 	: {}
			};
			
			
			var steps = parseInt($("#input_steps").val());
			if(typeof(steps) === undefined || steps == null || steps == ""){
				alert('steps를 입력해주세요.');
				return;
			}
			predictParam.algparam.steps = steps;
			
			console.log(predictParam);
			
			
			// ML Api 서버와 통신
			$.doPost({
				url : cv_apiAddr + "/arima/predict/",
				crossOrigin : true,
				data : predictParam,
				success : function(data){
					console.log(data);
					if(data.status === "success") {
						cfn_setTargetGrid(subPjtId,modelUid);
						cfn_postPredictModel(subPjtId,modelUid);
						cfn_setTargetImage(subPjtId,modelUid,'pr');
					} else {
						alert('오류가 발생하였습니다.');
						return;
					}
				}
			});
		});
	});
</script>
<div class="row">
	<div class="col-4 card l-20 mr-30" id="div_source">
		<dl class="row pt-3 mb-0">
			<dt class="col-12">
				SOURCE
				<img id="img_sourceGrid" style="width:15px;vertical-align:initial;cursor:pointer;" src="/images/common/icons/download_csv.png"/>
				<span id="span_sourceGrid_row_cnt" style="float:right;">0건</span>
			</dt>
		</dl>
		<div class="col-12 p-0">
			<div class="card m-2 p-2">
				<div class="row">
					<div class="col-12">
						<div id="sourceGrid" style="width:100%;height:500px;"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="col-3 card mr-10" id="div_control">
		<dl class="row pt-3 mb-0">
			<dt class="col-8">CONTROL</dt>
			<dd class="col-4">
				<button id="dataSubmitBtn" type="button" class="btn btn-outline-success">실행 <i class="far fa-save"></i></button>
			</dd>
	  	</dl>
	  	<div class="container pr-1 pl-1">
			<div class="card-title mb-0">
				<div class="row">
					<div class="col">
						<p class="h5 mb-0">
							<label class="mliFrame-name required"><strong>Label</strong></label>
						</p>
					</div>
				</div>
			</div>		
			<div class="card">
				<div id="labelGrid" style="width:100%;height:200px;"></div>
				<!-- <div id="featureGrid" style="width:100%;height:200px;"></div> -->
			</div>
			
			<!-- 1. steps -->
			<div class="card-title mb-0">
				<div class="row">
					<div class="col">
						<p class="h5 mb-1">
							<strong class="mliFrame-name required">steps</strong>
						</p>
					</div>
				</div>
			</div>		
			<div class="form-group">
				<input type="text" class="form-control-number" id="input_steps" value="1" step="1">
			</div>
			
		</div>
	</div>
	<div class="col-4 card" id="div_target">
		<dl class="row pt-3 mb-0">
			<dt class="col-12">
				Predict
				<img id="img_targetGrid" style="width:15px;vertical-align:initial;cursor:pointer;" src="/images/common/icons/download_csv.png"/>
				<span id="span_targetGrid_row_cnt" style="float:right;">0건</span>
			</dt>
		</dl>
		<div class="col-12 p-0">
			<div class="card m-2 p-2">
				<div class="row">
					<div class="col-12">
						<div id="targetGrid" style="width:100%;height:500px;"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
