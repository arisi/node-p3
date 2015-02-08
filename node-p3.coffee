#!/usr/bin/env coffee
#encoding: UTF-8

P3_START='~'.charCodeAt(0)
P3_END='^'.charCodeAt(0)
P3_ESC='#'.charCodeAt(0)

plist={}
plistp={}

stamp = () ->
  (new Date).getTime();

module.exports.plist=plist
module.exports.pack=pack = (pac) ->
  console.log "p3_outpac",pac

  buf=[]
  buf.push pac["proto"].charCodeAt(0)

  macs=pac["mac"].split(":")
  buf.push parseInt(macs[0],16)
  buf.push parseInt(macs[1],16)
  buf.push 0
  buf.push 0

  ips=pac["ip"].split(".")
  buf.push parseInt(ips[3])
  buf.push parseInt(ips[2])
  buf.push parseInt(ips[1])
  buf.push parseInt(ips[0])

  buf.push (pac["port"]&0xff)
  buf.push pac["port"]/0x100
  buf.push pac["data"].length
  for ch in pac["data"].split("")
    buf.push ch.charCodeAt(0)
  check=0
  for b in buf
    check^=b
  buf.push check
  buf.unshift P3_START
  buf.push P3_END
  console.log buf

  #hey!! escaping
  buf

module.exports.inchar=inchar = (p,ch,cb) ->
  if not plist[p]
    plist[p]={state: "init",p3: false, p3esc: false,p3buf: [],stamp: 0, id:"" }
    plistp[p]={}
    console.log "added plist",plist

  plist[p].exist=stamp()

  if ch==P3_START and not plist[p].p3esc and not plist[p].p3
    plist[p].p3=true
    plist[p].p3buf=[]
    return true
  else if ch==P3_END and not plist[p].p3esc and plist[p].p3
    #console.log "p3 packet in #{p},#{plist[p].p3buf}"
    plist[p].lastp3=stamp()
    cb p,plist[p].p3buf
    plist[p].p3=false
    return true
  else
    if not plist[p].p3
      return false
    else
      if plist[p].p3esc
        plist[p].p3esc=false
      else if ch==P3_ESC
        plist[p].p3esc=true
        return true
      plist[p].p3buf.push ch
  return true
