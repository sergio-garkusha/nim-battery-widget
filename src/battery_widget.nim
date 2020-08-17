import osproc, strutils, math

proc run() =
  let (res, code) = execCmdEx("ioreg -rc AppleSmartBattery")

  if code != 0:
    echo "[Error]: Battery Widget failed: ioreg not found"

  var current = "None"
  var maximum  = "None"

  for line in res.splitLines():
    let l = line.split('=')

    if l[0].contains("CurrentCapacity"):
      current = strip(l[1])
      if maximum != "None":
        break

    if l[0].contains("MaxCapacity"):
      maximum = strip(l[1])
      if current != "None":
        break

  let parsed_cur = current.parseFloat()
  let parsed_max = maximum.parseFloat()

  let charge = parsed_cur / parsed_max
  let treshold = charge * 10.0

  let slots = 10
  let filled = int32(round(treshold) * (slots / 10))
  let empty = slots - filled

  var color_out: string

  case filled
  of 0..3: color_out = "\x1b[;31m" # red
  of 4..6: color_out = "\x1b[;33m" # yellow
  else: color_out = "\x1b[;32m"    # green

  let color_reset = "\x1b[0m"

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
  echo color_out & "◼".repeat(filled) & "◻".repeat(empty) & color_reset

when isMainModule:
  run()
