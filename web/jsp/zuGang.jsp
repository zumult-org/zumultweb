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
    // ZuGang zu Allen Notwendigen Grundinformationen
   
    Corpus corpus = backendInterface.getCorpus(corpusID);
    
    Set<MetadataKey> speechEventMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEECH_EVENT);     
    List<String> speechEventSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, speechEventMetadataKeys,
            "SpeechEvent_", "Corpus_zumult:speechEventMetadataTableSelection");
    
    Set<MetadataKey> speakerMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEAKER);     
    List<String> speakerSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, speakerMetadataKeys,
            "Speaker_", "Corpus_zumult:speakerMetadataTableSelection");

    Set<MetadataKey> mediaMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.MEDIA);     
    List<String> mediaSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, mediaMetadataKeys,
            "Media_", "Corpus_zumult:mediaMetadataTableSelection");

    Set<MetadataKey> transcriptMetadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.TRANSCRIPT);     
    List<String> transcriptSelectionSet = ZuMultWebHelper.getSelectionSet(backendInterface, corpus, mediaMetadataKeys,
            "Transcript_", "Corpus_zumult:transcriptMetadataTableSelection");

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
        
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
        
        <link rel="stylesheet" type="text/css" href="../css/overview.css"/>       
        
        <script type="text/javascript" src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script type="text/javascript" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js" charset="utf8"></script>

        <script type="text/javascript" src="../js/zuGang.js" charset="utf8"></script>
        
        
        

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
            
            
            // ********************************
            // init the media table
            $(document).ready( function () {
                $('#mediaTable').DataTable( {
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
                            command : 'media'
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
                    <% for (String keyName : mediaSelectionSet){ %>
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
            // init the transcripts table
            $(document).ready( function () {
                $('#transcriptsTable').DataTable( {
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
                            command : 'transcripts'
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
                    <% for (String keyName : mediaSelectionSet){ %>
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
            
            
            function loadCorpusMetadata(corpusID){
                $.post(
                    BASE_URL + "/ZumultDataServlet",
                    { 
                        command: 'getCorpusMetadata',
                        format: 'html',
                        corpusID : corpusID
                    },
                    function( data ) {
                        $("#corpus-content").html(data);
                    }
                );                                                    
            }

            
        </script>
        
    </head>
    <body>
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

                        <!-- CORPUS tab header -->
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fs-4 px-4 py-3"
                                    id="corpus-tab"
                                    data-bs-toggle="tab"
                                    data-bs-target="#corpus-pane"
                                    type="button"
                                    role="tab"
                                    aria-controls="corpus-pane"
                                    aria-selected="false">
                                <i class="fa-solid fa-layer-group" aria-hidden="true"></i> Corpus
                            </button>
                        </li>

                        <!-- SPEECH EVENTS tab header -->
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active fs-4 px-4 py-3"
                                    id="speechEvents-tab"
                                    data-bs-toggle="tab"
                                    data-bs-target="#speechEvents-pane"
                                    type="button"
                                    role="tab"
                                    aria-controls="speechEvents-pane"
                                    aria-selected="true">
                                <i class="fa-solid fa-comments" aria-hidden="true"></i>&nbsp;Speech&nbsp;Events
                            </button>
                        </li>

                        <!-- SPEAKERS tab header -->
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fs-4 px-4 py-3"
                                    id="speakers-tab"
                                    data-bs-toggle="tab"
                                    data-bs-target="#speakers-pane"
                                    type="button"
                                    role="tab"
                                    aria-controls="speakers-pane"
                                    aria-selected="false">
                                <i class="fa-solid fa-users" aria-hidden="true"></i> Speakers
                            </button>
                        </li>

                        <!-- MEDIA tab header -->
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fs-4 px-4 py-3"
                                    id="media-tab"
                                    data-bs-toggle="tab"
                                    data-bs-target="#media-pane"
                                    type="button"
                                    role="tab"
                                    aria-controls="media-pane"
                                    aria-selected="false">
                                <i class="fa-solid fa-film" aria-hidden="true"></i> Media
                            </button>
                        </li>

                        <!-- TRANSCRIPTS tab header -->
                        <li class="nav-item" role="presentation">
                            <button class="nav-link fs-4 px-4 py-3"
                                    id="transcripts-tab"
                                    data-bs-toggle="tab"
                                    data-bs-target="#transcripts-pane"
                                    type="button"
                                    role="tab"
                                    aria-controls="transcripts-pane"
                                    aria-selected="false">
                                <i class="fa-regular fa-file-lines" aria-hidden="true"></i> Transcripts
                            </button>
                        </li>

                    </ul>

                    <!-- TAB CONTENT -->
                    <div class="tab-content pt-4" id="zuGangTabContent">

                        <!-- CORPUS -->
                        <div class="tab-pane fade show"
                             id="corpus-pane"
                             role="tabpanel"
                             aria-labelledby="corpus-tab"
                             tabindex="0">     
                            <div id="corpus-content">
                                Getting content from server...
                            </div>                    
                        </div>

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


                        <!-- MEDIA -->
                        <div class="tab-pane fade"
                             id="media-pane"
                             role="tabpanel"
                             aria-labelledby="media-tab"
                             tabindex="0">
                            <table id="mediaTable" class="stripe compact">
                                <thead>
                                    <tr>
                                        <th style="min-width: 100px;"></th>
                                        <th>ID</th>
                                        <%
                                            for (MetadataKey metadataKey : mediaMetadataKeys){
                                                String keyName = metadataKey.getName("en");
                                                if(!mediaSelectionSet.contains(keyName)) continue;
                                        %>
                                            <th><%=keyName%></th>    
                                        <%
                                            }
                                        %>
                                    </tr>
                                </thead>
                            </table>
                        </div> <!-- end media-pane -->


                        <!-- TRANSCRIPTS -->
                        <div class="tab-pane fade"
                             id="transcripts-pane"
                             role="tabpanel"
                             aria-labelledby="transcripts-tab"
                             tabindex="0">
                            <table id="transcriptsTable" class="stripe compact">
                                <thead>
                                    <tr>
                                        <th style="min-width: 100px;"></th>
                                        <th>ID</th>
                                        <%
                                            for (MetadataKey metadataKey : transcriptMetadataKeys){
                                                String keyName = metadataKey.getName("en");
                                                if(!transcriptSelectionSet.contains(keyName)) continue;
                                        %>
                                            <th><%=keyName%></th>    
                                        <%
                                            }
                                        %>
                                    </tr>
                                </thead>
                            </table>
                        </div> <!-- end transcripts-pane -->


                    </div> <!-- end tab-content -->

                </div> <!-- end right column -->

            </div> <!-- end row -->
        </div> <!-- end container-fluid -->                        
        <%@include file="../WEB-INF/jspf/metadataModal.jspf" %>        
        <%@include file="../WEB-INF/jspf/videoModal.jspf" %>
        
        <script>
            $(document).ready(function () {
                loadCorpusMetadata('<%= corpusID %>');
                document.getElementById('videoModal').addEventListener('hidden.bs.modal', function () {
                    // Stop video playback
                    stopVideo();
                });                
            });
        </script>
    </body>
</html>
