<html>
<head>
<style type="text/css">
@import "res/tabs.css";
@import "jquery/jquery.svg.css";
</style>
<script type="text/javascript" src="jquery/jquery-1.6.2.min.js"></script>
<script type="text/javascript" src="jquery/jquery.svg.js"></script>
</head>
<body>
<div style="float: right"><small><a href="https://github.com/liske/scotty-rel/" target="_blank" style="text-decoration: none">Scotty RELOADED</a></small></div>
<div class="tabs">
    <ul class="nav">
{
    foreach my $id (sort keys %views) {
	$OUT .= "<li><a href=\"#$id\"><span>$id</span></a></li>\n";
    }
}
    </ul>
{
    foreach my $id (sort keys %views) {
	$OUT .= "<div class=\"svgview\" id=\"$id\"></div>\n";
    }
}
</div>
<div><textarea style="width: 100%; height: 15%" id="log"></textarea></div>
<script type="text/javascript" src="res/index.js"></script>
<script type="text/javascript">
{
    my $first = 0;
    foreach my $id (sort keys %views) {
	$OUT .= "window.CURRENT_VIEW = \"$id\";\n" unless($first++);

	my $view = $views{$id};
	$OUT .= "\$('#$id').svg(\{loadURL: 'views/$view', onLoad: loadViewDone\});\n";
    }
}
</script>
</html>