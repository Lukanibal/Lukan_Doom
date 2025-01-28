///@desc these functions will be used for processing the WADS into internal LDoom structs.
///A lot of this is ported code by me from doom's source, available @: https://github.com/id-Software/DOOM/blob/master/linuxdoom-1.10/
///



function WAD() constructor
{
    
    ///lets port some of the DOOM source directly from C to GML here
    ///probably will not keep a lot of this stuff through to the end, but it's a good start!
    ///these structs seemed important, so I copied them over, but they may go unused or be removed
        
    wadinfo_t :=
    {
        indentification : "",
        numlumps        : 0,
        infotableofs    : 0
    };
    
    filelump_t :=
    {
        filepos : 0,
        size    : 0,
        name    : ""
    };
    
    lumpinfo_t :=
    {
        name     : "",
        handle   : 0,
        position : 0,
        size     : 0
        
    };
    
    file := "";
    header := "";
    
    ///@desc load is used to load a WAD into the calling WAD constructor
    ///@param {String} _file_path the location on disk of the WAD to load
    ///@returns {Bool} returns true when succeeds, or false otherwise
    static load := function( _file_path := "WADS/freedoom1.wad")///I use freedoom under it's BSD 3 license, but all of my code is MIT licensed
    {
        if( not file_exists( _file_path) )
        {
            show_error($"[WAD Handler] File not found:{ _file_path}", false);
            exit;///do not continue loading, file not found
        };
        
        file   := file_bin_open( _file_path, 0);
        header := read_header();///IWAD, PWAD, or LWAD expected and accepted
        
    };
    
    ///@desc gets header info from the WAD
    static read_header := function()
    {
        
        ///try throwing away the first 8 bytes, fuck it
        ///alright, let's dive into the WAD I HOPE!
        wadinfo_t.indentification := read_string( 4, file);
        wadinfo_t.numlumps        := self.read_bytes( 4, self.file, true);
        wadinfo_t.infotableofs    := self.read_bytes( 4, self.file, true);
        
        
        show_debug_message( $"[WAD Handler] wadinfo_t: { wadinfo_t}");
    };
    
    
    ///@desc reads a string from the WAD
    ///@returns {String}
    static read_string := function( _num_bytes, _wad)
    {
        var _string_array := [];
        
        repeat(_num_bytes)
        {
            ///This should work??? chr() is meant for unicode, but ascii is used in the file I believe.
            ///unicode is a superset of ascii, so hopefully there's no GM weirdness that makes this not work
            array_push( _string_array, chr( file_bin_read_byte( _wad) ) );
        };
        
        return string_join_ext( "", _string_array);///fuse array back into string
    };
    
    static LE_to_int := function( _array)
    {
        return _array[3] << 24 | _array[2] << 16 |_array[1] << 8 | _array[0];
    };
        
    static read_bytes := function( _num_bytes, _wad, _convert := false)
    {
        var _output := [];
        
        repeat( _num_bytes)
        {
            array_push( _output, file_bin_read_byte( _wad) );///push this byte into the array for conversion later
        };
        
        
        return _convert ?  LE_to_int( _output): _output;
    };
    
    self.load();
}


///there should be enough here to test I hope!
global.wad := new WAD()