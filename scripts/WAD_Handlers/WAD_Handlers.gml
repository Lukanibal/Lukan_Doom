///@desc these functions will be used for processing the WADS into internal LDoom structs.
///A lot of this is ported code by me from doom's source, available @: https://github.com/id-Software/DOOM/blob/master/linuxdoom-1.10/

///These structs are pretty similar to those found in w_wad.h

///Wad Info container
function WadInfo() constructor
{
    identification  := "";
    numlumps        := 0;
    infotableoffset := 0;
};

///Lump Directory data
function FileLump() constructor
{
    offset  := 0;
    size    := 0;
    name    := "";
};

//Actual lump info???
function LumpInfo() constructor
{
    name     := "";
    handle   := 0;
    position := 0;
    size     := 0;
    
};

function WAD() constructor
{
    system := "[WAD Handler v0.1]";
     
    file := "";
    header := {};
    
    wadinfo := new WadInfo();
    
    ///@desc load is used to load a WAD into the calling WAD constructor
    ///@param {String} _file_path the location on disk of the WAD to load
    ///@returns {Bool} returns true when succeeds, or false otherwise
    static load := function( _file_path := "WADS/freedoom1.wad")///I use freedoom under it's BSD 3 license, but all of my code is MIT licensed
    {
        if( not file_exists( _file_path) )
        {
            show_error($"{system} File not found:{ _file_path}", false);
            exit;///do not continue loading, file not found
        };
        
        file      := file_bin_open( _file_path, 0);
        header    := read_header();///IWAD, PWAD, or LWAD expected and accepted
        directory := read_directory();
    };
    
    ///@desc gets header info from the WAD
    static read_header := function()
    {
        
        ///try throwing away the first 8 bytes, fuck it
        ///alright, let's dive into the WAD I HOPE!
        wadinfo.identification  := read_string( 4, file, 0);
        wadinfo.numlumps        := self.read_bytes( 4, self.file, true, 4);
        wadinfo.infotableofs    := self.read_bytes( 4, self.file, true, 8);
        
        
        show_debug_message( $"{system} wadinfo: {wadinfo}");
    };
    
    
    ///@desc reads a string from the WAD
    ///@returns {String}
    static read_string := function( _num_bytes, _wad, _offset)
    {
        var _string_array := "";
        file_bin_seek( _wad, _offset);
        
        repeat( _num_bytes)
        {
            ///This should work??? chr() is meant for unicode, but ascii is used in the wads I believe.
            ///unicode is a superset of ascii, so hopefully there's no GM weirdness that makes this not work
            _string_array += chr( file_bin_read_byte( _wad) );
        };
        
        return _string_array;///fuse array back into string
    };
    
    static LE_to_int := function( _array)
    {
        ///using bitwise math to reconstruct the integer, this is literally the first time I have ever done bitwaise math, so I hope it's right!
        ///I referenced this: https://stackoverflow.com/questions/34943835/convert-four-bytes-to-integer-using-c
        
        return _array[3] << 24 | _array[2] << 16 |_array[1] << 8 | _array[0];
    };
        
    ///@desc this will read raw bytes form the WAD, _convert will do little endian to integer conversion and return the result, 
    ///otherwise it returns an array of the bytes in the order they were read.
    ///@returns {Array|Real}
    static read_bytes := function( _num_bytes, _wad, _convert := false, _offset := undefined)///I was ignoring the offsets because GM tracks the file position automatically, but that's obviously an issue now!
    {
        ///prepare the output
        var _output := [];
        
        ///seek to the correct offset!
        file_bin_seek( _wad, _offset);
        
        ///read the data
        repeat( _num_bytes)
        {
            array_push( _output, file_bin_read_byte( _wad) );///push this byte into the array for conversion later
        };
        
        ///feather ignore GM1063 once
        return _convert ? LE_to_int( _output): _output;
    };
    
    static read_directory := function()
    {
        var _directory := [];
        for( var _i := 0; _i < wadinfo.numlumps; _i++ ) 
        {
            var _fl     := new FileLump();
            var _offset := wadinfo.infotableoffset + _i * 16;
            _fl.offset  := read_bytes( 4, file, true, _offset);
            _fl.size    := read_bytes( 4, file, true, _offset + 4);
            _fl.name    := read_string( 8, file, _offset + 8);
            
            array_push(_directory, _fl);
        }
        
        show_debug_message( $"{system} directory listing: \n");
        
        var _len := array_length(_directory);
        
        for(var _i := 0; _i < _len; _i ++)
        {
            show_debug_message( $"{_directory[ _i]}\n");
        }
        
        return _directory;
    };
    
    self.load();
}


///there should be enough here to test I hope!
global.wad := new WAD();
game_end();///we're still ironing out the reading of the file, as it's all ouput to console, the window is basically useless rn.