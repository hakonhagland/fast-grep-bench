#include <stdio.h>
#include <sys/stat.h> 
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>


#define BLOCK_SIZE 8192       /* how much to read from file each time */
static char read_buf[BLOCK_SIZE + 1];

/*  reads a block from file, returns -1 on error, 0 on EOF, 
     else returns chars read, pointer to buf, and pointer to end of buf  */
size_t read_block( int fd, char **ret_buf, char **end_buf ) {
    int ret;
    char *buf = read_buf;
    size_t len = BLOCK_SIZE;
    while (len != 0 && (ret = read(fd, buf, len)) != 0) {
        if (ret == -1) {
            if (errno == EINTR)
                continue;
            perror( "read" );
            return ret;
        }
        len -= ret;
        buf += ret;
    }
    *end_buf = buf;
    *ret_buf = read_buf;
    return (size_t) (*end_buf - *ret_buf);
}

/* updates the line buffer with the char pointed to by cur,
   also updates cur
    */
int update_line_buffer( char **cur, char **line, size_t *llen, size_t max_line_len ) {
    if ( *llen > max_line_len ) {
        fprintf( stderr, "Too long line. Maximimum allowed line length is %ld\n",
                 max_line_len );
        return 0;
    }
    **line = **cur;
    (*line)++;
    (*llen)++;
    (*cur)++; 
    return 1;
}


/*    search for first pipe on a line (or next line if this is empty),
    assume line ptr points to beginning of line buffer.
  return 1 on success
  Return 0 if pipe could not be found for some reason, or if 
    line buffer length was exceeded  */
int search_field_start(
    int fd, char **cur, char **end_buf, char **line, size_t *llen, size_t max_line_len
) {
    char *line_start = *line;
    
    while (1) {
        if ( *cur >= *end_buf ) {
            size_t res = read_block( fd, cur, end_buf );        
            if (res <= 0) return 0;
        }
        if ( **cur == '|' ) break;
        /* Currently we just ignore malformed lines ( lines that do not have a pipe,
           and empty lines in the input */
        if ( **cur == '\n' ) {
            *line = line_start;
            *llen = 0;
            (*cur)++;
        }
        else {
            if (! update_line_buffer( cur, line, llen, max_line_len ) ) return 0;
        }
    }
    return 1;
}

/* assume cur points at starting pipe of field
  return -1 on read error, 
  return 0 if field len was too large for buffer or line buffer length exceed,
  else return 1
  and field, and  length of field
 */
int copy_field(
    int fd, char **cur, char **end_buf, char *field,
    size_t *flen, char **line, size_t *llen, size_t max_field_len, size_t max_line_len
) {
    *flen = 0;
    while( 1 ) {
        if (! update_line_buffer( cur, line, llen, max_line_len ) ) return 0;
        if ( *cur >= *end_buf ) {
            size_t res = read_block( fd, cur, end_buf );        
            if (res <= 0) return -1;
        }
        if ( **cur == '|' ) break;
        if ( *flen > max_field_len ) {
            printf( "Field width too large. Maximum allowed field width: %ld\n",
                    max_field_len );
            return 0;
        }
        *field++ = **cur;
        (*flen)++;
    }
    /* It is really not necessary to null-terminate the field 
       since we return length of field and also field could 
       contain internal null characters as well
    */
    //*field = '\0';
    return 1;
}

/* search to beginning of next line,
  return 0 on error,
  else return 1 */
int search_eol(
    int fd, char **cur, char **end_buf, char **line, size_t *llen, size_t max_line_len)
{
    while (1) {
        if ( *cur >= *end_buf ) {
            size_t res = read_block( fd, cur, end_buf );        
            if (res <= 0) return 0;
        }
        if ( !update_line_buffer( cur, line, llen, max_line_len ) ) return 0;
        if ( *(*cur-1) == '\n' ) {
            break;
        }
    }
    //**line = '\0'; // not necessary
    return 1;
}

#define MAX_FIELD_LEN 80  /* max number of characters allowed in a field  */
#define MAX_LINE_LEN 80   /* max number of characters allowed on a line */

/* 
   Get next field ( i.e. field #2 on a line). Fields are
   separated by pipes '|' in the input file.
   Also get the line of the field.
   Return 0 on error,
   on success: Move internal pointer to beginning of next line
     return 1 and the field.
 */
size_t get_field_and_line_fast(
    int fd, char *field, size_t *flen, char *line, size_t *llen
) {
    static char *cur = NULL;
    static char *end_buf = NULL;

    size_t res;
    if (cur == NULL) {
        res = read_block( fd, &cur, &end_buf );        
        if ( res <= 0 ) return 0;
    }
    *llen = 0;
    if ( !search_field_start( fd, &cur, &end_buf, &line, llen, MAX_LINE_LEN )) return 0;
    if ( (res = copy_field(
        fd, &cur, &end_buf, field, flen, &line, llen, MAX_FIELD_LEN, MAX_LINE_LEN
    ) ) <= 0)
        return 0;
    if ( !search_eol( fd, &cur, &end_buf, &line, llen, MAX_LINE_LEN ) ) return 0;
    return 1;
}

void search( char *filename, SV *href) 
{
    if( !SvROK( href ) || ( SvTYPE( SvRV( href ) ) != SVt_PVHV ) ) {
        croak( "Not a hash reference" );
    }

    int fd = open (filename, O_RDONLY);
    if (fd == -1) {
        croak( "Could not open file '%s'", filename );
    }
    char field[MAX_FIELD_LEN+1];
    char line[MAX_LINE_LEN+1];
    size_t flen, llen;
    HV *hash = (HV *)SvRV( href );
    while ( get_field_and_line_fast( fd, field, &flen, line, &llen ) ) {
        if( hv_exists( hash, field, flen ) )
            fwrite( line, sizeof(char), llen, stdout);
    }
    if (close(fd) == -1)
        croak( "Close failed" );
    
}
