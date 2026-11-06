<%@page import="java.util.Objects"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.TreeMap"%>
<%@page import="java.io.File"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.Configuration"%>
<%@page import="org.zumult.objects.TokenList"%>
<%@page import="org.zumult.objects.ObjectTypesEnum"%>
<%@page import="org.zumult.objects.IDList"%>
<%@page import="org.zumult.objects.Transcript"%>
<%@page import="org.zumult.io.FileIO"%>
<%@page import="org.zumult.io.Constants"%>
<%@page import="org.zumult.io.IOHelper"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>


<% 
    BackendInterface backend = BackendInterfaceFactory.newBackendInterface(); 
    
    // get parameters
    request.setCharacterEncoding("UTF-8");
    
    String transcriptID = request.getParameter("transcriptID");
    if (transcriptID==null){
        // redirect to error page
    }
    String customTitle = request.getParameter("customTitle");

    
    /**** START: for user defined vocabulary lists ****/
    
    
    Transcript transcript = backend.getTranscript(transcriptID);
    
    
    /**** END: for user defined vocabulary lists ****/
    
    
    String form = Objects.requireNonNullElse(request.getParameter("form"), "trans");
    String showNormDev = Objects.requireNonNullElse(request.getParameter("showNormDev"), "FALSE");
    String visSpeechRate = Objects.requireNonNullElse(request.getParameter("visSpeechRate"), "FALSE");

    String visIncidentNotTypes = Objects.requireNonNullElse(request.getParameter("visIncidentNotTypes"), "");
    String flattenSeg = Objects.requireNonNullElse(request.getParameter("flattenSeg"), "TRUE");

    String startAnnotationBlockID = Objects.requireNonNullElse(request.getParameter("startAnnotationBlockID"), "");
    String endAnnotationBlockID = Objects.requireNonNullElse(request.getParameter("endAnnotationBlockID"), "");
    String aroundAnnotationBlockID = Objects.requireNonNullElse(request.getParameter("aroundAnnotationBlockID"), "");

    // new for #272 / #12
    String speakerSelection = Objects.requireNonNullElse(request.getParameter("speakerSelection"), "");
    
    
    // issue #4
    String aroundTokenID = request.getParameter("aroundTokenID");   
    if (aroundTokenID==null){
        aroundTokenID = "";
    } else {
        aroundAnnotationBlockID = backend.getNearestAnnotationBlockID4TokenID(transcriptID, aroundTokenID);
    }
    
    
    String howMuchAround = Objects.requireNonNullElse(request.getParameter("howMuchAround"), "");
    
    String wordlistID = request.getParameter("wordlistID");    
    String pathToWordList = "";
    if (wordlistID!=null){
        pathToWordList = new File(getServletContext().getRealPath("/data/" + wordlistID + ".xml"))
                .toURI().toString();
    } else {
        wordlistID = "";
    }
    
    // new for issue #40
    String[] highlightIDsArray = new String[9];
    for (int i=1; i<=9; i++){
        String param = request.getParameter("highlightIDs" + Integer.toString(i));
        if (param!=null){
            highlightIDsArray[i-1] = param;
        } else {
            highlightIDsArray[i-1] = "";
        }        
    }
    


    /**** START: for user defined vocabulary lists and for action sequences****/
    
    
    //String highlightIDs = request.getParameter("highlightIDs");
    String tokenList = request.getParameter("tokenList");
    if (tokenList==null){   
        String query = request.getParameter("q");
        if (query!=null && !query.isEmpty()){
            IDList tokenIDs = backend.searchTokensForTranscript(query, null, null, null, null, null, transcriptID, "id", null);
            IDList lemmas = backend.searchTokensForTranscript(query, null, null, null, null, null, transcriptID, "lemma", null);
            highlightIDsArray[0] = String.join(" ", tokenIDs);
            tokenList = String.join(";", lemmas);
        } else{
            tokenList = "";
        }
    }
    if (tokenList==null){
        tokenList="";
    }
    
    
    String startTokenID = request.getParameter("startTokenID");
    String endTokenID = request.getParameter("endTokenID");    
    
    String makeVisibleID = request.getParameter("makeVisibleID");    
  
        
    if (startTokenID!=null && endTokenID!=null){

        /* if firstTokenId and lastTokenId are specified, than aroundAnnotationBlockID and aroundTokenID should be ignored; */
        aroundAnnotationBlockID = "";
        aroundTokenID = "";
        startAnnotationBlockID = backend.getNearestAnnotationBlockID4TokenID(transcriptID, startTokenID);;
        endAnnotationBlockID = backend.getNearestAnnotationBlockID4TokenID(transcriptID, endTokenID);;

        if(howMuchAround.length()>0){
            startAnnotationBlockID = transcript.getAnnotationBlockID(startAnnotationBlockID, -Integer.parseInt(howMuchAround));
            endAnnotationBlockID = transcript.getAnnotationBlockID(endAnnotationBlockID, Integer.parseInt(howMuchAround));

        }
    }
        
        
    //}
    
    /**** END: for user defined vocabulary lists ****/
                    
    String corpusID = backend.getCorpus4Event(backend.getEvent4SpeechEvent(backend.getSpeechEvent4Transcript(transcriptID)));
    String speechEventID = backend.getSpeechEvent4Transcript(transcriptID); //transcriptID.substring(0,18);
    String eventID = backend.getEvent4SpeechEvent(speechEventID); // transcriptID.substring(0,12);
    IDList videos = backend.getVideos4Transcript(transcriptID);   
    IDList audios = backend.getAudios4Transcript(transcriptID);
    
    String previousTranscriptID = null;
    String followingTranscriptID = null;
    IDList allTranscriptsForThisCorpus = backend.getTranscripts4Corpus(corpusID);
    int index = allTranscriptsForThisCorpus.indexOf(transcriptID);
    if (index>0){
        previousTranscriptID = allTranscriptsForThisCorpus.get(index-1);
    } else {
        previousTranscriptID = allTranscriptsForThisCorpus.get(allTranscriptsForThisCorpus.size()-1);
    }
    if (index<allTranscriptsForThisCorpus.size()-1){
        followingTranscriptID = allTranscriptsForThisCorpus.get(index+1);    
    } else {
        followingTranscriptID = allTranscriptsForThisCorpus.get(0);
    }
    
    
    String speechEventName = backend.getSpeechEvent(speechEventID).getName();
    
    Transcript partTranscript = transcript;
    if (aroundAnnotationBlockID.length()>0 && howMuchAround.length()>0){
        startAnnotationBlockID = transcript.getAnnotationBlockID(aroundAnnotationBlockID, -Integer.parseInt(howMuchAround));
        endAnnotationBlockID = transcript.getAnnotationBlockID(aroundAnnotationBlockID, Integer.parseInt(howMuchAround));
    }
    if (startAnnotationBlockID.length()>0 && endAnnotationBlockID.length()>0){
        partTranscript = transcript.getPart(startAnnotationBlockID, endAnnotationBlockID, true);
    }
    TokenList lemmaList4Transcript = partTranscript.getTokenList("lemma");
    //TokenList posList4Transcript = partTranscript.getTokenList("pos");
    
    double startTime = partTranscript.getStartTime();
    
    
    String[][] transcriptParameters = {
        {"FORM", form},
        {"SHOW_NORM_DEV", showNormDev},
        {"VIS_SPEECH_RATE", visSpeechRate},
        {"VIS_INCIDENT_NOT_TYPES", visIncidentNotTypes},
        {"START_ANNOTATION_BLOCK_ID", startAnnotationBlockID}, 
        {"END_ANNOTATION_BLOCK_ID", endAnnotationBlockID},
        {"AROUND_ANNOTATION_BLOCK_ID", aroundAnnotationBlockID},
        {"HOW_MUCH_AROUND", howMuchAround},
        //{"HIGHLIGHT_IDS", highlightIDsForCurrentTranscript},
        {"HIGHLIGHT_IDS_1", highlightIDsArray[0]},
        {"HIGHLIGHT_IDS_2", highlightIDsArray[1]}, 
        //{"EXTRA_HIGHLIGHT_IDS", extraHighlightIDsForCurrentTranscript}, 
        //{"TOKEN_LIST_URL", pathToWordList}
        {"SPEAKER_SELECTION", speakerSelection}         
    };
    
    //String transcriptHTML = new IOHelper().applyInternalStylesheetToString(Constants.ISOTEI2HTML_STYLESHEET2, transcript.toXML(), transcriptParameters); 
    //String transcriptSVG = new IOHelper().applyInternalStylesheetToString("/org/zumult/io/isotei2score_svg.xsl", transcript.toXML(), transcriptParameters);  
    
    String[][] largeSVGParameters = {
        {"START_ANNOTATION_BLOCK_ID", startAnnotationBlockID}, 
        {"END_ANNOTATION_BLOCK_ID", endAnnotationBlockID},
        {"SIZE", "medium"},        
    };
    String largeSVG = new IOHelper().applyInternalStylesheetToString("/org/zumult/io/isotei2score_svg.xsl", transcript.toXML(), largeSVGParameters);  
    
    String[][] wordlistParameters ={
        {"TOKEN_LIST_URL", pathToWordList},
        {"TOKEN_LIST_ARRAY", tokenList}        
    };
    //String wordListHTML = new IOHelper().applyInternalStylesheetToString("/org/zumult/io/tokenlist2html_table.xsl", lemmaList4Transcript.toXML(), wordlistParameters); 
    //String posListHTML = new IOHelper().applyInternalStylesheetToString("/org/zumult/io/tokenlist2html_table.xsl", posList4Transcript.toXML()); 

    //http://zumult.ids-mannheim.de/ProtoZumult/ZumultDataServlet?command=getVTT&transcriptID=FOLK_E_00069_SE_01_T_01
    String vttURL = Configuration.getWebAppBaseURL() + "/ZumultDataServlet?command=getVTT&transcriptID=" + transcriptID;
    
%>

<%@include file="../WEB-INF/jspf/locale.jspf" %>     

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ZuMult - ZuViel</title>

        <style type="text/css">
            td {
                /*max-width: 200px;*/
                white-space: normal;
                word-wrap: break-word;
            }          
            #zuVielTabs .nav-link {
                color: #343a40;
                background-color: #f8f9fa;
            }

            #zuVielTabs .nav-link.active {
                color: white;
                background-color: rgb(120,120,120);
                border-color: #343a40;
            }            
            
        </style>

        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
        
        <link rel="stylesheet" type="text/css" href="../css/overview.css"/>       
        <link rel="stylesheet"  href="../css/transcript.css"/>
        <link rel="stylesheet"  href="../css/transcript_print.css"media="print"/>         <!-- issue #54 -->
        <link rel="stylesheet" href="../css/query.css"/>
        
        <%@include file="../WEB-INF/jspf/zuVielJS.jspf" %>     
        
        <script type="text/javascript" src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>

        <script type="text/javascript" src="../js/zuGang.js" charset="utf8"></script>
        <script type="text/javascript" src="../js/metadata.js"></script>
        <script type="text/javascript" src="../js/download.js"></script>
        <script type="text/javascript" src="../js/collections.js"></script>
        
        <script>
            // probably all variables from the URL should be mirrored in this way
            var speechEventID = '<%= speechEventID %>';
            var transcriptID = '<%= transcriptID %>';
            var wordlistID = '<%= wordlistID %>';
            var form = '<%= form %>';
            var showNormDev = '<%= showNormDev %>';
            var visSpeechRate = '<%= visSpeechRate %>';

            var startSelection = '<%= startAnnotationBlockID %>';
            var endSelection = '<%= endAnnotationBlockID %>';
            
            var startAnnotationBlockID = '<%= startAnnotationBlockID %>';
            var endAnnotationBlockID = '<%= endAnnotationBlockID %>';
            var startTime = <%= startTime %>;

            var vttURL = '<%= vttURL %>';
            
            var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';
            
            var highlightIDs1 = '<%= highlightIDsArray[0] %>';
            var highlightIDs2 = '<%= highlightIDsArray[1] %>';
            var highlightIDs3 = '<%= highlightIDsArray[2] %>';
            var highlightIDs4 = '<%= highlightIDsArray[3] %>';
            
            var speakerSelection = '<%= speakerSelection %>';
            

            function init(){
                initialiseMedia();
                
                $("#tr" + startSelection).addClass("selectionStart");
                $("#tr" + endSelection).addClass("selectionEnd");
            }            
            
            $(document).ready(function(){
        
                $("#selectLang").on("change", function(){
                    var value = $(this).val();
                    var urlTest = new URL(window.location.href);
                    urlTest.searchParams.set('lang',value);
                    window.location = urlTest;
                });
            });
            
        </script>
        <script src="../js/media.js"></script>
        
        
    </head>
    <body onload="init()" id="zuviel-body">        
        <%@include file="../WEB-INF/jspf/transcriptNav.jspf" %>                                                
        <div class="container-fluid px-4 mt-4">
            <!-- TAB HEADINGS -->
            <ul class="nav nav-tabs nav-justified" id="zuVielTabs" role="tablist">

                <!-- LINES tab header -->
                <li class="nav-item" role="presentation">
                    <button class="nav-link active"
                            id="line-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#lines-pane"
                            type="button"
                            role="tab"
                            aria-controls="lines-pane"
                            aria-selected="false">
                        <i class="fa-solid fa-align-left" aria-hidden="true"></i> Lines
                    </button>
                </li>

                <!-- PARTITUR tab header -->
                <li class="nav-item" role="presentation">
                    <button class="nav-link"
                            id="partitur-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#partitur-pane"
                            type="button"
                            role="tab"
                            aria-controls="partitur-pane"
                            aria-selected="true">
                        <i class="fa-solid fa-bars-staggered" aria-hidden="true"></i> Partitur
                    </button>
                </li>

                <!-- ANNOTATIONS tab header -->
                <li class="nav-item" role="presentation">
                    <button class="nav-link"
                            id="annotations-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#annotations-pane"
                            type="button"
                            role="tab"
                            aria-controls="annotations-pane"
                            aria-selected="false">
                        <i class="fa-solid fa-highlighter" aria-hidden="true"></i> Annotations
                    </button>
                </li>
            </ul>
        </div>        <!-- END tab heads -->
        
        
        <!-- TAB CONTENT -->
        <div class="tab-content pt-4" id="zuVielTabContent">

            <!-- LINES -->
            <div class="tab-pane fade show active"
                 id="lines-pane"
                 role="tabpanel"
                 aria-labelledby="lines-tab"
                 tabindex="0">     
                    <div class="row">

                        <!-- *********************** -->
                        <!-- *****LEFT COL    ****** -->
                        <!-- *********************** -->
                        <div class="col-auto d-flex flex-column align-items-end" id="columnLeft" style="height: 85vh;">
                            <!-- **************************** -->
                            <!-- ***** WORDLIST             * -->
                            <!-- **************************** -->
                            <div id="wordlist-container" class="container flex-grow-1 overflow-auto px-5">
                                <i class="fas fa-spinner fa-spin"></i>
                                <p style="color:gray"><%=myResources.getString("WaitWordlistLoading")%></p>                            
                            </div>
                        </div>


                        <!-- *********************** -->
                        <!-- ****  CENTER COL   **** -->
                        <!-- *********************** -->
                        <div class="col d-flex flex-column" id="columnCenter" style="height: 100vh;">

                            <!-- *** EXPAND BEFORE *** -->
                            <% if (startAnnotationBlockID!=null && startAnnotationBlockID.length()>0) { %>
                                <button type="button" 
                                        onclick="expandTranscript('-1')"
                                        class="btn btn-outline-dark btn-sm" 
                                        style="width: 100%; border: none; margin-bottom: 5px; margin-left: 15px; margin-right: 15px; padding: 2px;">
                                    <i class="fas fa-angle-double-up" aria-hidden="true"></i>
                                </button>                
                            <% } %>

                            <!-- *******************************  -->
                            <!-- *** LOAD A PREVIEW IF NEEDED *** -->
                            <!-- *******************************  -->
                            <% if (startAnnotationBlockID==null || startAnnotationBlockID.length()==0) { 
                                Transcript previewTranscript = partTranscript.getPart(1, 12);
                                String previewHTML = new IOHelper().applyInternalStylesheetToString(Constants.ISOTEI2HTML_STYLESHEET2, previewTranscript.toXML(), transcriptParameters); 
                            %>
                            <div class="container" id="preview-container" style="position:relative; width:100%; height: 800px; cursor: not-allowed">
                                <div id="preview-overlay" style="background-color: gray; position:absolute; top:0; left:0; bottom:0; right:0; 
                                     z-index: 10; opacity: 0.3;">   
                                     <div style="position: absolute;  top: 50%; left: 50%;">
                                        <span class="badge badge-pill badge-primary" 
                                              style="transform: rotate(-20deg); font-size:1.5rem; opacity: 1 !important; margin:20px;">Preview</span><br/>
                                        <i class="fas fa-spinner fa-spin fa-5x"></i>                            
                                    </div>
                                </div>
                                <div id="preview-transcript" style="position:absolute; top:0; left:0; bottom:0; right:0; max-height:800px; overflow: hidden;">
                                    <%= previewHTML %>
                                </div>
                            </div>
                            <% } %>

                            <!-- *******************************  -->
                            <!-- *******************************  -->
                            <!-- *******************************  -->

                            <div class="container flex-grow-1 overflow-auto" id="transcript-container">
                                <p style="color:gray; font-size:14pt; padding-top:20px;">
                                    <i class="fas fa-spinner fa-spin"></i>
                                    <%=myResources.getString("WaitTranscriptLoading")%>
                                </p>
                            </div>

                            <!-- *******************************  -->
                            <!-- *******************************  -->
                            <!-- *******************************  -->

                            <!-- *** EXPAND AFTER *** -->                    
                            <% if (endAnnotationBlockID!=null && endAnnotationBlockID.length()>0) { %>
                                <button type="button" 
                                        onclick="expandTranscript('1')"
                                        class="btn btn-outline-dark btn-sm" 
                                        style="width: 100%; border: none;margin-top: 5px; margin-left: 15px; margin-right: 15px; padding: 2px;">
                                    <i class="fas fa-angle-double-down" aria-hidden="true"></i>
                                </button>                
                            <% } %>
                        </div>





                        <!-- *********************** -->
                        <!-- *********************** -->
                        <!-- *********************** -->
                        <!-- right column --> 
                        <% if (!videos.isEmpty() || !audios.isEmpty()){ %>
                        <div class="col-auto" id="columnRight" style="min-width: 540px;">
                            <div style="position: fixed;">                    
                                <%@include file="../WEB-INF/jspf/zuVielDensityNav.jspf" %> 
                                <%@include file="../WEB-INF/jspf/zuVielMediaPlayers.jspf" %> 
                            </div>    
                        </div> 
                        <% } %>
                        <!-- end right column -->


                    </div>
                </div>
            </div>
                
        </div>
            
    </div>
        
    <!-- ************************************** -->
    <!-- ************************************** -->
    <!-- ************************************** -->

    <iframe id="secretIFrame" src="" style="display:none; visibility:hidden;"></iframe>    

    <%@include file="../WEB-INF/jspf/annotationsModal.jspf" %>                                                
    <%@include file="../WEB-INF/jspf/partiturModal.jspf" %>                                                
    <%@include file="../WEB-INF/jspf/svgModal.jspf" %>                                                
    <%@include file="../WEB-INF/jspf/metadataModal.jspf" %>                                                
    <%@include file="../WEB-INF/jspf/parametersModal.jspf" %>                                                
    <%@include file="../WEB-INF/jspf/downloadModal.jspf" %>                                                
    <!-- issue #53 -->
    <%@include file="../WEB-INF/jspf/POSHelperModal.jspf" %>                                                
    <!-- issue #55 -->
    <%@include file="../WEB-INF/jspf/printDownloadWordlistModal.jspf" %>                                                

    <script type="text/javascript">
        reloadWordlist();
        reloadTranscript('<%= makeVisibleID %>');
        reloadSVG('small');
        jump(startTime);
        getMasterMediaPlayer().pause();

    </script>

    </body>
</html>
