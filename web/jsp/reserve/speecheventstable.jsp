<%@page import="java.util.Arrays"%>
<%@page import="java.util.HashSet"%>
<%@page import="org.zumult.objects.ObjectTypesEnum"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="java.util.List"%>
<%@page import="org.zumult.objects.Location"%>
<%@page import="org.zumult.objects.MetadataKey"%>
<%@page import="org.zumult.objects.Speaker"%>
<%@page import="org.zumult.objects.IDList"%>
<%@page import="java.util.Set"%>
<%@page import="org.zumult.objects.Corpus"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<%@include file="../WEB-INF/jspf/locale.jspf" %>     
<%
    String corpusID = request.getParameter("corpusID");
    String transcriptID = null; // needed to inform menu bar
    

    String pageName = "ZuMult";
    String pageTitle = myResources.getString("SpeechEventsPL") + " (" + corpusID + ")";
    //String imgSrc = "../images/eslo_bandeau.jpg";
   
    BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
    Corpus corpus = backendInterface.getCorpus(corpusID);
    Set<MetadataKey> metadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEECH_EVENT);     

    List<String> selectionSet = new ArrayList<>();
    for (MetadataKey mk : metadataKeys){
        selectionSet.add(mk.getName("en"));
    }
    
    // this is new for #270, 07-03-2026
    // I am going out of may way here to make this robust
    // I will hopefully be given an award for this
    // the FIFA Peace Prize will do for now
    MetadataKey selectionKey = backendInterface.findMetadataKeyByID("Corpus_zumult:speechEventMetadataTableSelection");
    if (selectionKey!=null){
        String allMetadataNames = corpus.getMetadataValue(selectionKey);
        if (allMetadataNames!=null && allMetadataNames.length()>0){
            List<String> configuredSelectionSet = new ArrayList<>();
            String[] tokenizedMetadataNames = allMetadataNames.split(";");
            for (String mn : tokenizedMetadataNames){
                MetadataKey mk = backendInterface.findMetadataKeyByID("SpeechEvent_" + mn);
                if (mk!=null){
                    configuredSelectionSet.add(mk.getName("en"));
                }
            }
            if (!(configuredSelectionSet.isEmpty())){
                selectionSet = configuredSelectionSet;
            }
        }
    }
    



%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ZuMult - Speech events overview</title>
        <style type="text/css">
            .id-column {font-weight: bold;}
            .actions-column {white-space: nowrap;}
            td {
                /*max-width: 200px;*/
                white-space: normal;
                word-wrap: break-word;
            }            
        </style>
        <link rel="stylesheet" href="../css/overview.css"/>       
        <!-- <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/> -->
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">


        <script type="text/javascript" src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        <!-- <script type="text/javascript" src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script> -->               
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
        
        
        

        <script type="text/javascript">
            var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';

            // ********************************
            // init the table
            $(document).ready( function () {
                //$('#myTable').DataTable();
                $('#myTable').DataTable( {
                    autoWidth: false,
                    serverSide: true,
                    processing : true,
                    language: {
                        processing: "Loading data from server..."  // custom message
                    },                    
                    ajax: {
                        url: '../DataTableServlet', // <-- your server endpoint
                        type: 'POST',       // or 'GET' depending on your backend
                        data: {
                            corpusID : '<%=corpusID%>',
                            command : 'communications'
                        }
                    },  
                    columnDefs : [
                        { targets: 0, className: 'actions-column'},
                        { targets: 1, className: 'id-column'}
                    ],    
                    columns: [
                    {
                      data: 'Actions', 
                      title: 'Actions',
                      orderable: false,
                      searchable: false
                    },  
                    { 
                        data: 'ID', 
                        title: 'ID'
                    },
                    <% for (String keyName : selectionSet){ %>
                        { 
                            data: '<%= keyName %>', 
                            title: '<%= keyName %>'
                        },
                    <% } %>
                    ],                    
                    pageLength: 20,
                    dom: 'Bfrtip',
                    buttons: [
                        {
                            extend: 'colvis',
                            columns: ':not(.noVis)',
                            text: 'Select columns'       
                        }
                    ]
                } );
            } ); 
            
            function openLineTranscript(transcriptID){
                let url = "./zuViel.jsp?transcriptID=" + transcriptID;
                window.open(url, '_blank');    
            }
            
            function openScoreTranscript(transcriptID){
                let url = "./zuPass.jsp?transcriptID=" + transcriptID;
                window.open(url, '_blank');    
            }

            function playAudio(audioID, element){
                let randomID = 'id-' + Date.now() + '-' + Math.random().toString(36).substr(2, 5);
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getAudio',
                        audioID: audioID
                    },
                    function( data ) {
                        let audioURL = $(data).find("audio").first().text();
                        if (audioURL.length === 0){
                            alert('No audio for ' + transcriptID);                            
                        } else {
                            let audioHTML = "<audio type=\"audio/mp3\" src=\"" + audioURL + "\" id=\"" + randomID + "\"></audio>";
                            let pauseHTML = "<i class=\"fa-solid fa-pause\"></i>";
                            $(element).html(audioHTML + pauseHTML);
                            const audio = $('#' + randomID)[0];
                            // Check if the audio is ready to play
                            if (audio.readyState >= 2) { // 2 = HAVE_CURRENT_DATA
                                audio.play(); // Start playing
                            } else {
                                // If the audio is not ready, wait until it is loaded
                                audio.addEventListener('canplay', function onCanPlay() {
                                audio.play(); // Start playing
                                audio.removeEventListener('canplay', onCanPlay); // Remove the event listener
                                });
                            }  
                            element.onclick = function(){
                                stopAudio(this, randomID, audioID);
                            };                                
                        }
                    }
                );                        

            }

            function stopAudio(parent, elementID, audioID){
                const audio = $('#' + elementID)[0];
                audio.pause();
                let playHTML = "<i class=\"fa-solid fa-play\"></i>";
                $(parent).html(playHTML);
                parent.onclick = function(){
                    playAudio(audioID, this);
                };                
            }
            

            function openSpeechEventMetadata(speechEventID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getEventHTML',
                        speechEventID : speechEventID
                    },
                    function( data ) {
                        $("#metadata-body").html(data);
                        $("#metadata-title").html(speechEventID);
                        $('#metadataModal').modal("toggle");
                    }
                );                                    
            }
            
            
            function showSpeakers(speechEventID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getSpeakerMetadata',
                        format: 'html',
                        speechEventID : speechEventID
                    },
                    function( data ) {
                        $("#metadata-body").html(data);
                        $("#metadata-title").html("<i class=\"fa-solid fa-comment-dots\" aria-hidden=\"true\"></i> " + speechEventID);
                        $('#metadataModal').modal("toggle");
                    }
                );                                                    
            }
            
            function playVideo(videoID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getVideo',
                        videoID: videoID
                    },
                    function( data ) {
                        let time = 0.0;
                        let videoURL = $(data).find("video").first().text();
                        if (videoURL.length === 0){
                            alert('No video found with ID ' + videoID);                            
                        } else {
                            insertVideoPlayer(videoURL, Math.max(0.0, time - 1.0));
                        }
                    }
                );                    

            }

            function insertVideoPlayer(videoURL, time){
                let videoHTML = "<video id=\"modal-video\" controls=\"controls\" type=\"video/mp4\" src=\"" + videoURL +  "\"></video>";
                $('#video-div').html(videoHTML);                
                const video = $('#modal-video')[0];
                // Check if the video is ready to play
                if (video.readyState >= 2) { // 2 = HAVE_CURRENT_DATA
                    video.currentTime = time; // Set the playback position
                    video.play(); // Start playing
                } else {
                    // If the audio is not ready, wait until it is loaded
                    video.addEventListener('canplay', function onCanPlay() {
                        video.currentTime = time; // Set the playback position
                        video.play(); // Start playing
                        video.removeEventListener('canplay', onCanPlay); // Remove the event listener
                    });
                }  
                $('#videoModal').modal("toggle");
            }

            function stopVideo(){
                const video = $('#modal-video')[0];
                video.pause();
                video.remove();
            }
            
            
            
        </script>
        
    </head>
    <body margin-top="80px;">
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>                                                
        
        <div class="row">
            <div class="col-sm-1">
            </div>
            <div class="col-sm-10">
                <table id="myTable" class="stripe compact">
                    <thead>
                        <tr>
                            <th style="min-width: 100px;"></th>
                            <th>ID</th>
                            <%
                                for (MetadataKey metadataKey : metadataKeys){
                                    String keyName = metadataKey.getName("en");
                                    if(!selectionSet.contains(keyName)) continue;

                            %>
                                <th><%=keyName%></th>    
                            <%
                                }
                            %>
                        </tr>
                    </thead>
                </table>
            </div>
            <div class="col-sm-1">
            </div>
        </div>
        <%@include file="../WEB-INF/jspf/metadataModal.jspf" %>        
        <%@include file="../WEB-INF/jspf/videoModal.jspf" %>
        
        <script>
            $(document).ready(function () {
                document.getElementById('videoModal').addEventListener('hidden.bs.modal', function () {
                    // Stop video playback
                    stopVideo();
                });                
            });
        </script>
        
    </body>
</html>
