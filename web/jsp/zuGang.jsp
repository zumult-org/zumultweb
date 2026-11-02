<%@page import="java.util.Arrays"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="org.zumult.objects.Location"%>
<%@page import="org.zumult.objects.MetadataKey"%>
<%@page import="org.zumult.objects.Speaker"%>
<%@page import="org.zumult.objects.IDList"%>
<%@page import="org.zumult.objects.ObjectTypesEnum"%>
<%@page import="org.zumult.objects.Corpus"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.web.ZuMultWebHelper"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<%@include file="../WEB-INF/jspf/locale.jspf" %>     
<%
    BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
    IDList allCorpusIDs = backendInterface.getCorpora();
    String corpusID = request.getParameter("corpusID");
    if (corpusID==null){
        corpusID = allCorpusIDs.get(0);
    }
    String transcriptID = null; // needed to inform menu bar
    

    String pageName = "ZuMult";
    String pageTitle = "ZuGang" + " (" + corpusID + ")";
   
    Corpus corpus = backendInterface.getCorpus(corpusID);
    
    Set<MetadataKey> speechEventMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEECH_EVENT);     
    List<String> speechEventSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, speechEventMetadataKeys,
            "SpeechEvent_", "Corpus_zumult:speechEventMetadataTableSelection");
    
    Set<MetadataKey> speakerMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEAKER);     
    List<String> speakerSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, speakerMetadataKeys,
            "Speaker_", "Corpus_zumult:speakerMetadataTableSelection");
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ZuMult - ZuGang</title>
        <style type="text/css">
            .id-column {font-weight: bold;}
            .actions-column {white-space: nowrap;}
            td {
                /*max-width: 200px;*/
                white-space: normal;
                word-wrap: break-word;
            }          
            #zuGangTabs .nav-link {
                color: #343a40;
                background-color: #f8f9fa;
            }

            #zuGangTabs .nav-link.active {
                color: white;
                background-color: rgb(120,120,120);
                border-color: #343a40;
            }            
            
            #corpusList .list-group-item.active {
                color: white;
                background-color: rgb(120,120,120);
                border-color: #343a40;
            }            
        </style>
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        
        <link rel="stylesheet" href="../css/overview.css"/>       
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
        
        
        

        <script type="text/javascript">
            var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';

            // ********************************
            // init the speech events table
            $(document).ready( function () {
                $('#speechEventsTable').DataTable( {
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
                    <% for (String keyName : speechEventSelectionSet){ %>
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
            
            // ********************************
            // init the speakers table
            $(document).ready( function () {
                $('#speakersTable').DataTable( {
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
                            command : 'speakers'
                        }
                    },  
                    columnDefs : [
                        { targets: 1, className: 'id-column'}
                    ],    
                    columns: [
                    {
                      data: 'Actions', 
                      title: 'Actions',
                      orderable: false,
                      searchable: false
                    },  
                    { data: 'ID', title: 'ID'},
                    <% for (String keyName : speakerSelectionSet){ %>
                        { data: '<%= keyName %>', title: '<%= keyName %>'},
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
            
            
            function openTranscript(transcriptID){
                let url = "./zuViel.jsp?transcriptID=" + transcriptID;
                window.open(url, '_blank');    
            }
            
            function openZupass(transcriptID){
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
                                stopAudio(this, randomID);
                            };                                
                        }
                    }
                );                        
                
            }
            
            function stopAudio(parent, audioID){
                const audio = $('#' + audioID)[0];
                audio.pause();
                let playHTML = "<i class=\"fa-solid fa-play\"></i>";
                $(parent).html(playHTML);
                parent.onclick = function(){
                    playbackAudio(this);
                };                
            }
            

            function openMetadata(speechEventID){
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
            
            // ********************************
            function openSpeakerMetadata(speakerID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getSpeakerMetadata',
                        speakerID : speakerID
                    },
                    function( data ) {
                        $("#metadata-body").html(data);
                        $("#metadata-title").html(speakerID);
                        $('#metadataModal').modal("toggle");
                    }
                );                                    
            }
            
            // ********************************
            
            function showSpeechEvents(speakerID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getSpeechEventMetadata',
                        format: 'html',
                        speakerID : speakerID
                    },
                    function( data ) {
                        $("#metadata-body").html(data);
                        $("#metadata-title").html("<i class=\"fa-solid fa-comment-dots\" aria-hidden=\"true\"></i> " + speakerID);
                        $('#metadataModal').modal("toggle");
                    }
                );                                                    
            }
            
            
            
        </script>
        
    </head>
    <body margin-top="80px;">
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>                                                
        
<div class="container-fluid px-4 mt-4" style="width: 90%;">
    <div class="row g-4">

        <!-- LEFT COLUMN: CORPUS SELECTION -->
        <div class="col-md-3 col-lg-2">
            <div class="card">
                <div class="card-header fw-bold">
                    Corpora
                </div>
                <div class="list-group list-group-flush" id="corpusList">
                    <% for (String cID : allCorpusIDs){ %>
                        <a 
                            href="zuGang.jsp?corpusID=<%= cID %>"
                            class="list-group-item list-group-item-action 
                                <% if (cID.equals(corpusID)) { %>
                                active
                                <% } %>
                                ">
                            <%= cID %>
                        </a>
                    <% } %>
                    <!-- More corpus IDs will go here -->
                </div>
            </div>
        </div>

        <!-- RIGHT COLUMN: TABS -->
        <div class="col-md-9 col-lg-10">
            <!-- TAB HEADINGS -->
            <ul class="nav nav-tabs nav-justified" id="zuGangTabs" role="tablist">

                <li class="nav-item" role="presentation">
                    <button class="nav-link fs-4 px-4 py-3"
                            id="corpus-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#corpus-pane"
                            type="button"
                            role="tab"
                            aria-controls="corpus-pane"
                            aria-selected="false">
                        Corpus
                    </button>
                </li>

                <li class="nav-item" role="presentation">
                    <button class="nav-link active fs-4 px-4 py-3"
                            id="speechEvents-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#speechEvents-pane"
                            type="button"
                            role="tab"
                            aria-controls="speechEvents-pane"
                            aria-selected="true">
                        Speech Events
                    </button>
                </li>

                <li class="nav-item" role="presentation">
                    <button class="nav-link fs-4 px-4 py-3"
                            id="speakers-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#speakers-pane"
                            type="button"
                            role="tab"
                            aria-controls="speakers-pane"
                            aria-selected="false">
                        Speakers
                    </button>
                </li>

                <li class="nav-item" role="presentation">
                    <button class="nav-link fs-4 px-4 py-3"
                            id="media-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#media-pane"
                            type="button"
                            role="tab"
                            aria-controls="media-pane"
                            aria-selected="false">
                        Media
                    </button>
                </li>

                <li class="nav-item" role="presentation">
                    <button class="nav-link fs-4 px-4 py-3"
                            id="transcripts-tab"
                            data-bs-toggle="tab"
                            data-bs-target="#transcripts-pane"
                            type="button"
                            role="tab"
                            aria-controls="transcripts-pane"
                            aria-selected="false">
                        Transcripts
                    </button>
                </li>

            </ul>

            <!-- TAB CONTENT -->
            <div class="tab-content pt-4" id="zuGangTabContent">

                <!-- SPEECH EVENTS -->
                <div class="tab-pane fade show active"
                     id="speechEvents-pane"
                     role="tabpanel"
                     aria-labelledby="speechEvents-tab"
                     tabindex="0">                
                    <table id="speechEventsTable" class="stripe compact">
                        <thead>
                            <tr>
                                <th style="min-width: 100px;"></th>
                                <th>ID</th>
                                <%
                                    for (MetadataKey metadataKey : speechEventMetadataKeys){
                                        String keyName = metadataKey.getName("en");
                                        if(!speechEventSelectionSet.contains(keyName)) continue;
                                %>
                                    <th><%=keyName%></th>    
                                <%
                                    }
                                %>
                            </tr>
                        </thead>
                    </table>
                </div>

                <!-- SPEAKERS -->
                <div class="tab-pane fade"
                     id="speakers-pane"
                     role="tabpanel"
                     aria-labelledby="speakers-tab"
                     tabindex="0">


                    <table id="speakersTable" class="stripe compact">
                        <thead>
                            <tr>
                                <th></th>
                                <th>ID</th>
                                <%
                                    for (MetadataKey metadataKey : speakerMetadataKeys){
                                        String keyName = metadataKey.getName("en");
                                        if(!speakerSelectionSet.contains(keyName)) continue;
                                %>
                                    <th><%=keyName%></th>    
                                <%
                                    }
                                %>
                            </tr>
                        </thead>
                    </table>
                </div>                        


                <!-- CORPUS -->
                <div class="tab-pane fade"
                     id="corpus-pane"
                     role="tabpanel"
                     aria-labelledby="corpus-tab"
                     tabindex="0">
                <p>To DO</p>
            </div> <!-- end corpus-pane -->

                    </div> <!-- end tab-content -->

                </div> <!-- end right column -->

            </div> <!-- end row -->
        </div> <!-- end container-fluid -->                        
        <%@include file="../WEB-INF/jspf/metadataModal.jspf" %>        
    </body>
</html>
