/* AMMS client (C) 2012 */
/* require jquery, jquery.json */

ammsd_uri = "http://127.0.0.1:81/ammsd.fcgi";

var amms = {

    exe: function (uri, data){

        if (uri == null)
            return undefined;
        
        data = "q=" + encodeURIComponent ($.toJSON (data)); // manually encode to prevent "+" sign

        var jqxhr = $.ajax ({type: "POST", async: false, url: uri, data: data});
        
        var amms_response;
        
        if (jqxhr.status == 200)
            amms_response = $.parseJSON (jqxhr.responseText);

        if (amms_response == null){
            amms_response = { b: undefined, s: undefined };
        }

        return { 
            responseText: jqxhr.responseText,
            status: jqxhr.status,
            statusText: jqxhr.statusText,
            b: amms_response.b,
            s: amms_response.s
        };
    }
};
