<cfsetting requesttimeout="120" showdebugoutput="false">
<cfscript>
    dsn = "enquetes";
    result = { ok = false, error = "", count = 0, tables = [] };
    try {
        q = queryExecute(
            "SELECT TABLE_SCHEMA, TABLE_NAME
               FROM INFORMATION_SCHEMA.TABLES
              WHERE TABLE_TYPE = 'BASE TABLE'
              ORDER BY TABLE_SCHEMA, TABLE_NAME",
            [], { datasource: dsn }
        );
        for (row in q) arrayAppend(result.tables, row.TABLE_SCHEMA & "." & row.TABLE_NAME);
        result.ok = true;
        result.count = q.recordCount;
    } catch (any e) {
        result.error = e.message & " :: " & e.detail;
    }
</cfscript>
<cfoutput>
<h2>Lucee dump self-test</h2>
<p>Page executed: yes — раз ты это видишь, ни Lucee, ни app-auth страницу не блокнули.</p>
<p>Datasource: <strong>#dsn#</strong></p>
<cfif result.ok>
    <p style="color:green">DATASOURCE OK — найдено base tables: #result.count#</p>
    <ol><cfloop array="#result.tables#" index="t"><li>#t#</li></cfloop></ol>
<cfelse>
    <p style="color:red">DATASOURCE FAILED</p>
    <pre>#encodeForHtml(result.error)#</pre>
</cfif>
</cfoutput>