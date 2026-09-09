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
    String pageTitle = "Speakers overview";
    //String imgSrc = "../images/eslo_bandeau.jpg";

    BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
    Corpus corpus = backendInterface.getCorpus(corpusID);
    Set<MetadataKey> metadataKeys = corpus.getMetadataKeys(ObjectTypesEnum.SPEAKER);     

    List<String> selectionSet = new ArrayList<>();
    for (MetadataKey mk : metadataKeys){
        selectionSet.add(mk.getName("en"));
    }
    
    // this is new for #270, 07-03-2026
    // I am going out of may way here to make this robust
    // I will hopefully be given an award for this
    // the FIFA Peace Prize will do for now
    MetadataKey selectionKey = backendInterface.findMetadataKeyByID("Corpus_zumult:speakerMetadataTableSelection");
    if (selectionKey!=null){
        String allMetadataNames = corpus.getMetadataValue(selectionKey);
        if (allMetadataNames!=null && allMetadataNames.length()>0){
            List<String> configuredSelectionSet = new ArrayList<>();
            String[] tokenizedMetadataNames = allMetadataNames.split(";");
            for (String mn : tokenizedMetadataNames){
                MetadataKey mk = backendInterface.findMetadataKeyByID("Speaker_" + mn);
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
        <title>ZuMult - Speakers overview</title>
        <style type="text/css">
            .id-column {font-weight: bold;}
        </style>
        
        <link rel="stylesheet" href="../css/overview.css"/>       
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">
        
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
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
                    <% for (String keyName : selectionSet){ %>
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
        
        <div class="row">
            <div class="col-sm-1">
            </div>
            <div class="col-sm-10">
                <table id="myTable" class="stripe compact">
                    <thead>
                        <tr>
                            <th></th>
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
