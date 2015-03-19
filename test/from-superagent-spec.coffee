{Left, Right} = require 'fantasy-eithers'
{runLog} = require 'kefir-contrib-run'
{fromSuperAgent} = require '../src/index'

mockReq = (r) -> () ->
  end: (f) ->
    process.nextTick((-> r.fold(f, (a) -> f(null, a))))

describe "fromSuperAgent", ->
  it "should emit response from request as value", ->
    expect(runLog(fromSuperAgent(mockReq(Right(10))))).to.become([Right(10)])

  it "should emit request error as error", ->
    err = new Error("Timeout")
    expect(runLog(fromSuperAgent(mockReq(Left(err))))).to.become([Left(err)])

