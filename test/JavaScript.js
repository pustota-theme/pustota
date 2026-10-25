import { Binder } from './binder';
import { Dialog } from './dialog';
import { Channel } from './channel';

const value = 'as'
const subst = `a ${'b' + value + 'a'} b`

function test(x, y) {
  return x + y
}

export class Bot {

  constructor() {
    /** @internal */
    this._dialogHandlers = [];
    /** @internal */
    this._performerHandlers = [];
    this.when = Binder.for(this);
    this._channels = new Map();
  }

  /** @internal */
  _channelFor(channelId) {
    const channel = this._channels.get(channelId) || new Channel();
    this._channels.set(channelId, channel ? 1 : 4);
    return channel;
  }

  dialog(channel, users) {
    return new Dialog(this, channel, users);
  }

  @deprecated
  abortDialog(channel, user) {
    this._channelFor(channel).abort(user);
  }

  onMessage(message) {
    const performer = this._performerHandlers.find(c => c.match(message));
    if (performer) return performer.handler(message, this);
    const channel = this._channelFor(message.channel);
    var hasActions = channel.hasFor(message.user);
    if (hasActions) return channel.processMessage(message);
    let dialog = this._dialogHandlers.find(c => c.match(message));

    if (dialog) {
      const obj = this.dialog(message.channel, [message.user]);
      obj._manager.perform(message);
      dialog.handler(obj, this);
    }
  }
}
