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

    String pageName = "ZuMult";
    String pageTitle = "Speech events overview";
    //String imgSrc = "../images/eslo_bandeau.jpg";
   
    BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
    Corpus corpus = backendInterface.getCorpus(corpusID);
    Set<MetadataKey> metadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEECH_EVENT);     

    Set<String> selectionSet = new HashSet<>();
    for (MetadataKey mk : metadataKeys){
        selectionSet.add(mk.getName("en"));
    }



%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ZuMult - Speech events overview</title>
        <style type="text/css">
            .id-column {font-weight: bold;}
        </style>
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        
        <link rel="stylesheet" href="../css/overview.css"/>       
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
        
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>                
        <script src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
        
        
        

        <script type="text/javascript">
            var BASE_URL = '<%= Configuration.getWebAppBaseURL() %>';

            // ********************************
            // init the table
            $(document).ready( function () {
                //$('#myTable').DataTable();
                $('#myTable').DataTable( {
                    serverSide: true,
                    ajax: {
                        url: '../DataTableServlet', // <-- your server endpoint
                        type: 'GET',       // or 'GET' depending on your backend
                        data: {
                            corpusID : '<%=corpusID%>',
                            command : 'communications'
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
            
            function openTranscript(transcriptID){
                let url = "./zuViel.jsp?transcriptID=" + transcriptID;
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
                                //audio.currentTime = time; // Set the playback position
                                audio.play(); // Start playing
                            } else {
                                // If the audio is not ready, wait until it is loaded
                                audio.addEventListener('canplay', function onCanPlay() {
                                //audio.currentTime = time; // Set the playback position
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
            
            
        </script>
        
    </head>
    <body>
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
    </body>
</html>
