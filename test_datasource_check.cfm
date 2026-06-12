<cfprocessingdirective pageEncoding="utf-8">
<cfsetting requesttimeout="3600" showdebugoutput="false">
<cfscript>
    // ===== CONFIG =====
    dsn       = "enquetes";
    tableName = "dbo.Branches";    // <-- exact schema.table; fix if it's actually named differently
    fileName  = "Branches.csv";
    // ==================

    try {
        data = queryExecute("SELECT * FROM #tableName# WITH (NOLOCK)", [], { datasource: dsn });
    } catch (any e) {
        // on error: show a readable message instead of a broken download
        writeOutput("<h3>Query failed for " & encodeForHtml(tableName) & "</h3><pre>"
                  & encodeForHtml(e.message & " :: " & e.detail) & "</pre>");
        abort;
    }

    cols = listToArray(data.columnList);

    // proper CSV escaping: NULL -> empty, double up quotes, wrap if value has quote/comma/newline
    function csv(v){
        if (isNull(arguments.v)) return "";
        var s = toString(arguments.v);
        if (find('"', s) || find(',', s) || find(chr(13), s) || find(chr(10), s))
            s = '"' & replace(s, '"', '""', "all") & '"';
        return s;
    }

    sb = createObject("java","java.lang.StringBuilder").init();
    sb.append(chr(65279));   // UTF-8 BOM so Excel reads French accents correctly

    hdr = [];
    for (c in cols) arrayAppend(hdr, csv(c));
    sb.append(arrayToList(hdr, ",") & chr(13) & chr(10));

    for (row in data){
        rec = [];
        for (c in cols) arrayAppend(rec, csv(row[c]));
        sb.append(arrayToList(rec, ",") & chr(13) & chr(10));
    }

    csvBytes = charsetDecode(sb.toString(), "utf-8");
</cfscript>
<cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
<cfcontent type="text/csv" variable="#csvBytes#" reset="true">