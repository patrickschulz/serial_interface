`ifndef _INCLUDES_SVH_
  `define _INCLUDES_SVH_
  `define CMD_LEN 2 /* length of the commands in bits */
  `define DATA_LEN 8 /* length of the possible to be stored data */
  `define ASCII_LEN 8 /* length of an ASCII character in bitss */

  typedef enum bit [2:0] {
    RESET_ST,
    UPDATE_ST,
    IDLE_ST,
    RCV_CMD_ST,  /* currently receiving a command */
    ACK_CMD_ST,  /* acknowledged a command successfully */
    RCV_DATA_ST,  /* receiving data */
    SND_DATA_ST  /* sending data */
  } ctrl_state_t;  /* fsm states for the daisychain controller to be in */

  typedef enum bit [`CMD_LEN-1:0] {
    RESET_CMD,
    START_SND_CMD,  /* start transmission of saved data */
    START_RCV_CMD,  /* start receiving of data */
    UPDATE_CMD  /* update the shift registers output cells */
  } ctrl_cmd_t;  /* command types to be received from the micro */
`endif
