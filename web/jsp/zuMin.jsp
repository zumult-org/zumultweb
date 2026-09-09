<%-- 
    Document   : zuPass
    Created on : 10.12.2024, 16:31:06
    Author     : bernd
--%>
<%@page import="org.zumult.io.MausConnection"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="org.zumult.backend.Configuration"%>
<%@page import="org.zumult.objects.Media"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="org.zumult.objects.Transcript"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.io.IOHelper"%>




<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<%
    BackendInterface backend = BackendInterfaceFactory.newBackendInterface(); 
    String transcriptID = request.getParameter("transcriptID");
    
    String annotationBlockID = request.getParameter("annotationBlockID");
    if (transcriptID==null || annotationBlockID==null){
        // redirect to error page
    }

    String pageName = "ZuMin";
    String pageTitle = transcriptID + " - " + annotationBlockID;
    
    String speechEventID = backend.getSpeechEvent4Transcript(transcriptID);
    String corpusID = backend.getCorpus4Event(backend.getEvent4SpeechEvent(speechEventID));
    
    String videoIDsParameter = request.getParameter("videoIDs");
    List<String> videoIDs = new ArrayList<>();
    if (videoIDsParameter==null || videoIDsParameter.length()==0){
        videoIDs = backend.getVideos4SpeechEvent(speechEventID);
    } else {
        String[] videoIDsSplit = videoIDsParameter.split("\\|");
        videoIDs.addAll(Arrays.asList(videoIDsSplit));
    }
    
    String audioIDsParameter = request.getParameter("audioIDs");
    List<String> audioIDs = new ArrayList<>();
    if (videoIDs.isEmpty() || (audioIDsParameter==null || audioIDsParameter.length()==0)){
        audioIDs = backend.getAudios4SpeechEvent(speechEventID);
    } else {
        String[] audioIDsSplit = audioIDsParameter.split("\\|");
        audioIDs.addAll(Arrays.asList(audioIDsSplit));
    } 

    String vttURL = Configuration.getWebAppBaseURL() + "/ZumultDataServlet?command=getVTT&transcriptID=" + transcriptID;
    
    Transcript transcript = backend.getTranscript(transcriptID);
    double startTime = transcript.getTimeForID(annotationBlockID);
    String annotationBlockEndID = backend.getAnnotationBlock(transcriptID, annotationBlockID).getEnd();
    double stopTime = transcript.getTimeForID(annotationBlockEndID);
    
    
    String[][] transcriptParameters = {
        {"FORM", "trans"},
        {"SHOW_NORM_DEV", "FALSE"},
        {"VIS_SPEECH_RATE", "FALSE"},
        {"AROUND_ANNOTATION_BLOCK_ID", annotationBlockID},
        {"HOW_MUCH_AROUND", "3"},
        {"HIGHLIGHT_ANNOTATION_BLOCK", annotationBlockID},        
        {"TOKEN_LIST_URL", ""},
        {"DROPDOWN", "FALSE"},
        {"PLAYPAUSEBUTTONS", "FALSE"},
        {"TRANSLATION", ""}
    };
    
    String transcriptHTML = new IOHelper().applyInternalStylesheetToString(Constants.ISOTEI2HTML_STYLESHEET2, 
            transcript.toXML(), 
            transcriptParameters); 



%>

<%@include file="../WEB-INF/jspf/locale.jspf" %> 

<html>
        <html>
            <head>
                <link rel="stylesheet" href="../css/transcript.css"/>
                <script src="../js/media_zumin.js"></script>
                <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>        
                <script src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
                <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
                <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
                <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>                

                <script>
                    // probably all variables from the URL should be mirrored in this way
                    var speechEventID = '<%= speechEventID %>';
                    var transcriptID = '<%= transcriptID %>';
                    var annotationBlockID = '<%= annotationBlockID %>';
                    var vttURL = '<%= vttURL %>';
                    var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';   
                    var startTime = <%= startTime %>
                    var stopTime = <%= stopTime %>                    
                    var xPerSecond = 600;
                    
                    var svg;                    
                    var pt;
                    
                    function loadMicroView(){
                        $.post(
                            BASE_URL + "/ZumultDataServlet",
                            { 
                                command: 'getMicroView',
                                transcriptID: transcriptID,
                                annotationBlockID: annotationBlockID,
                                xPerSecond : xPerSecond
                            },
                            function( data ) {
                                $('#microViewDiv').html(data);
                                // need to do this only once per document
                                svg = document.getElementById('pitchSVG');
                                pt = svg.createSVGPoint();                                
                                
                            }
                        );                    
                        
                    }
                    
                    function rangeSliderChanged(inputId){
                      const input = document.getElementById(inputId);
                      const newValue = input.value;
                      if (inputId==='playbackSpeedRange'){
                          const video = document.getElementById("master-video");
                          if (video!==null){
                              video.playbackRate = newValue / 100.0;
                          }
                          const audio = document.getElementById("master-audio");
                          if (audio!==null){
                              audio.playbackRate = newValue / 100.0;
                          }
                      } else if (inputId==='zoomRange'){
                          stretchX(newValue);
                      }
                        
                    }
                    
                    function stretchX(percentage) {
                      const svg = document.getElementById("outerSVGWrapper");
                      const factor = percentage / 100;
                      svg.style.transform = `scaleX(${factor})`;
                      svg.style.transformOrigin = "left center";
                    }                    
                    
                </script>
                
            </head>
    <body onload="initialiseMedia()">
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>                                                
               
        <div id="video-form" class="row justify-content-center" style="margin-top:80px;">
            <div class="col-1"></div>
            <div class="col-5">
                <table>
                    <%
                        if (!audioIDs.isEmpty() && videoIDs.isEmpty()){
                    %>
                    <tr>
                    <% for (int i=0; i<Math.min(audioIDs.size(),2); i++){
                        String audioID = audioIDs.get(i);
                        Media audio = backend.getMedia(audioID);
                        String url = audio.getURL();
                        String id = "master-audio";
                        if (i>0){
                            id = "audio-" + Integer.toString(i);
                        }
                    %>
                    <td>
                        <audio controls="controls" name="audio" id="<%= id %>" style="margin-right:30px">
                            <source src="<%= url %>" type="audio/wav"/>
                        </video>
                    </td>
                    <%
                        }
                    %>
                    </tr>
                    <%
                        }
                    %>
                    <tr>
                        <% 
                            for (int i=0; i<Math.min(videoIDs.size(),2); i++){
                                String videoID = videoIDs.get(i);
                                Media video = backend.getMedia(videoID);
                                String url = video.getURL();
                                String id = "master-video";
                                if (i>0){
                                    id = "video-" + Integer.toString(i);
                                }
                        %>
                        <td>
                            <video width="480" height="320" controls="controls" name="video" id="<%= id %>" style="margin-right:30px">
                                <source src="<%= url %>" type="video/mp4"/>
                                <track label="trans" kind="subtitles" srclang="de" src="<%= vttURL %>" default="default">
                                <track label="norm" kind="subtitles" srclang="de" src="<%= vttURL + "&subtitleType=norm"%>">                
                            </video>
                        </td>
                        <td>
                            <div style="background: #f8f9fa; height: 270px; border-radius: 3px; padding: 3px;">
                                <a href="javascript:addVideoImageToCollection('<%= videoID %>')" 
                                   title="<%=myResources.getString("AddVideoImageCollection")%>" style="color:black">
                                    <i class="far fa-plus-square"></i>
                                </a><br/>          
                                <a href="javascript:getVideoImage('<%= videoID %>')" 
                                   title="<%=myResources.getString("ExtractVideoImage")%>" style="color:black">
                                    <i class="fas fa-camera-retro"></i>
                                </a><br/>
                                <a href="javascript:frameBackward()" title="<%=myResources.getString("PrecedingFrame")%>" style="color:black">
                                    <i class="fas fa-step-backward"></i>
                                </a><br/>
                                <a href="javascript:frameForward()" title="<%=myResources.getString("NextFrame")%>" style="color:black">
                                    <i class="fas fa-step-forward"></i>
                                </a>
                            </div>                        
                        </td>
                    <%
                        }
                    %>    
                    </tr>
                </table>
                
            </div>
            <div class="col-5">
                <%= transcriptHTML %>
            </div>
            <div class="col-1"></div>
        </div>
            
        <div id="zumi-controls" class="row mt-2">
            <div class="col-1"></div>
            <div class="col-10 overflow-auto">

                <div class="row justify-content-center">
                    <div class="btn-group m-3" role="group"> 
                         <button class="btn btn-outline-dark btn-lg" title="To start of section" onclick="backward-fast()">
                          <i class="fa-solid fa-backward-fast"></i>
                        </button>                                    

                        <button class="btn btn-outline-dark btn-lg" title="Ten frames (0.25s) backward" onclick="wind(-0.25)">
                          <i class="fa-solid fa-backward"></i>
                        </button>                                    

                        <button class="btn btn-outline-dark btn-lg" title="One frame (0.04s) backward" onclick="frameBackward()">
                          <i class="fa-solid fa-backward-step"></i>
                        </button>                                    

                        <button class="btn btn-dark btn-lg pl-5 pr-5" title="Play section" onclick="playSelection()" id="sync-play-pause-button">
                          <i class="fa-solid fa-play"></i><i class="fa-light fa-pipe-section ml-3"></i>
                        </button>                                    

                        <button class="btn btn-outline-dark btn-lg" title="One frame (0.04s) forward" onclick="frameForward()">
                          <i class="fa-solid fa-forward-step"></i>
                        </button>                                    

                        <button class="btn btn-outline-dark btn-lg" title="Ten frames (0.25s) forward" onclick="wind(0.25)">
                          <i class="fa-solid fa-forward"></i>
                        </button>     

                         <button class="btn btn-outline-dark btn-lg" title="To end of section" onclick="forward-fast()">
                          <i class="fa-solid fa-forward-fast"></i>
                        </button>       
                    </div>
                            
        <div class="row g-3 align-items-center">
            <!-- Slider 1 -->
            <div class="col-12 col-md-6">
              <label for="playbackSpeedRange" class="form-label d-flex justify-content-between">
                <span>Speed</span>
                <!-- value badge placed to the right -->
                <span id="playbackSpeedValue" class="badge bg-secondary">100</span>
              </label>
              <input
                id="playbackSpeedRange"
                class="form-range"
                type="range"
                min="50"
                max="150"
                step="1"
                value="100"
              >
            </div>

            <!-- Slider 2 -->
            <div class="col-12 col-md-6">
              <label for="zoomRange" class="form-label d-flex justify-content-between">
                <span>Zoom</span>
                <span id="zoomValue" class="badge bg-secondary">100</span>
              </label>
              <input
                id="zoomRange"
                class="form-range"
                type="range"
                min="50"
                max="400"
                step="5"
                value="100"
              >
            </div>
          </div>

                        </div>
            </div>

            <div class="col-1"></div>

        </div>
        
        <div id="partitur-form" class="row mt-2">
            <div class="col-1"></div>
            <div class="col-10 overflow-auto" id="microViewDiv">
                <p>
                    <table class="table">
                        <tr>
                            <td>
                                <img src="../images/loading.gif"/>                                
                            </td>
                            <td>
                                ZuMin is zoomin' in. <br/>
                                Getting forced alignment via <b>MAUS</b> (Thanks to BAS Munich), <br/>
                                pitch contour via <b>Praat</b> (Thanks to Paul Boersma)
                                <% if (videoIDs.size()>0){ %><br/>
                                and video stills via <b>FFMPEG</b>.       
                                <% } %>
                            </td>
                        </tr>

                    </table>
                </p>
            </div>
            <div class="col-1"></div>
        </div>
        
        <script type="text/javascript">
            // to keep the range sliders updated
            const sliders = [
              { inputId: 'playbackSpeedRange', valueId: 'playbackSpeedValue' },
              { inputId: 'zoomRange', valueId: 'zoomValue' }
            ];

            sliders.forEach(({ inputId, valueId }) => {
              const input = document.getElementById(inputId);
              const valueEl = document.getElementById(valueId);
              if (!input || !valueEl) return;

              // Initialize display
              valueEl.textContent = input.value;

              // Update on input for instant feedback
              input.addEventListener('input', () => {
                valueEl.textContent = input.value;
                rangeSliderChanged(inputId);
              });
            });

            loadMicroView();
            jump(startTime);
            getMasterMediaPlayer().pause();
        </script>
        
    </body>
</html>
