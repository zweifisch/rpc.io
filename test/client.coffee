mocha.setup 'bdd'
expect = chai.expect

rpcio = require 'rpc.io-client'
socket = rpcio 800

describe 'call', ->

    it 'should support callback', (done)->

        socket.call 'add', n1:1, n2:9, (err, result)->
            expect(result).to.equal 10
            done()

    it 'should return an promise', (done)->

        result = socket.call 'add', n1: 2, n2: 7
        result.then (value)->
            expect(value).to.equal 9
            done()

    it 'should time out', (done)->

        result = socket.call 'sleep', time: 1000
        result.then (value)->
            done new Error 'failed to time out'
        result.catch (err)->
            expect(err).to.equal 'timeout'
            done()

    it 'should wake up on time', (done)->

        result = socket.call 'sleep', time: 500
        result.then (value)->
            done()
        result.catch (err)->
            done new Error 'failed to wakeup'

    it 'should catch exceptions', (done)->

        result = socket.call 'error', msg: 'foo'
        result.then (value)->
            done new Error 'failed to cache exception'
        result.catch (err)->
            expect(err).to.equal 'foo'
            done()

    it 'should fail on unregistered method', (done)->

        result = socket.call 'foo', foo: 'bar'
        result.catch (err)->
            done()

mocha.run()
