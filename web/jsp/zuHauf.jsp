<%-- 
    Document   : downloadCorpus
    Created on : 23.09.2026, 09:25:08
    Author     : bernd
--%>

<%@page import="org.zumult.objects.IDList"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@include file="../WEB-INF/jspf/locale.jspf" %>     
<!DOCTYPE html>
<html>
    <%
       String corpusID = request.getParameter("corpusID");
       String transcriptID = null; // needed to inform menu bar
            
       BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
       String language = request.getParameter("lang");
       if (language==null){
           language="de";
       }
       IDList speechEventIDs = backendInterface.getSpeechEvents4Corpus(corpusID);
    %>
    
    <head>  
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ZuMult: Download corpus files</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>                

        <link rel="stylesheet" href="../css/overview.css"/>       
        <style type="text/css">
            .modal-dialog {
              max-width: 90%;
            }            
        </style>
        
        <script>
            var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';
           
            $(document).ready(function(){
        
                $("#selectLang").on("change", function(){
                    var value = $(this).val();
                    var urlTest = new URL(window.location.href);
                    urlTest.searchParams.set('lang',value);
                    window.location = urlTest;
                });
            });
        </script>
        
    </head>
    <body style="margin-top: 80px;">
        <%
           String pageTitle = myResources.getString("CorpusQuickDownload");
           String pageName = "ZuMult";
        %>
            
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>                                                
        <div class="row">
            <div class="col-sm-2">
            </div>
            <div class="col-sm-8">
                <table class="table table-striped">
                    <tr>
                        <th>Speech event</th>
                        <th>Video</th>
                        <th>Audio</th>
                        <th>Transcript</th>
                    </tr>
                    <% 
                     for (String speechEventID : speechEventIDs){                        
                        IDList videoIDs = backendInterface.getVideos4SpeechEvent(speechEventID);
                        IDList audioIDs = backendInterface.getAudios4SpeechEvent(speechEventID);
                        IDList transcriptIDs = backendInterface.getTranscripts4SpeechEvent(speechEventID);
                    %>
                    <tr>
                        <td><%= speechEventID %></td>
                        
                        <!-- Videos-->
                        <td>
                            <% for (String videoID : videoIDs){ 
                                String videoURL = backendInterface.getMedia(videoID).getURL();
                                String videoName = videoURL.substring(videoURL.lastIndexOf("/")+1);
                            %>
                            <a href="<%= videoURL %>" download="<%= videoName %>">
                                <%= videoName %>
                            </a>
                            <% } %>
                        </td>
                        
                        <!-- Audios-->
                        <td>
                            <% for (String audioID : audioIDs){ 
                                String audioURL = backendInterface.getMedia(audioID).getURL();
                                String audioName = audioURL.substring(audioURL.lastIndexOf("/")+1);
                            %>
                            <a href="<%= audioURL %>"  download="<%= audioName %>">
                                <%= audioName %>
                            </a>
                            <% } %>
                        </td>
                        
                        <!-- Transcripts -->
                        <td>
                            <% for (String audioID : audioIDs){ 
                                String transcriptURL = backendInterface.getMedia(audioID).getURL().replaceAll("\\.wav", ".xml");
                                String transcriptName = transcriptURL.substring(transcriptURL.lastIndexOf("/")+1);
                            %>
                            <a href="<%= transcriptURL %>"  download="<%= transcriptName %>">
                                <%= transcriptName %>
                            </a>
                            <% } %>
                        </td>

                    </tr>
                    
                    <% } %>
                </table>
            </div>
        </div>
    </body>
</html>
