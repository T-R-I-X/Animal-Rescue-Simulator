export type PathListener = (newValue: any, oldValue: any) -> ()
export type ReplicaListener = (replica: Replica) -> ()

export type ReplicaParams = {
	ClassName: string,
	Data: { [string]: any },
	Tags: { [string]: any },
	Replication: (string | { Player })?,
}

export type Path = { string }
export type Replica = {
	ClassName: string,
	Children: { Replica },
	Data: { any },
	Tags: { any },
	Replication: { any },

	SetParent: (self: Replica, replica: Replica) -> (),
	DestroyFor: (self: Replica, Player) -> (),

	SetValue: (self: Replica, path: string, value: any) -> (),
	SetValues: (self: Replica, path: string, values: { [string]: any }) -> (),
	ArrayInsert: (self: Replica, path: string, value: any) -> (),
	ArraySet: (self: Replica, path: string, index: number, value: any) -> (),
	ArrayRemove: (self: Replica, path: string, index: number) -> (),

	ConnectOnServerEvent: (self: Replica, listener: () -> ()) -> (),
	ConnectOnClientEvent: (self: Replica, listener: () -> ()) -> (),

	ListenToChildAdded: (self: Replica, child: Replica) -> (),
	ListenToRaw: (self: Replica, listener: (listenerType: string, path: { string }, any) -> ()) -> (),
	ListenToChange: (self: Replica, path: string, listener: (newValue: any, oldValue: any) -> ()) -> (),
    ListenToNewKey: (self: Replica, path: string, listener: (value: any, newKey: string) -> ()) -> (),
	ListenToKeyChanged: (self: Replica, path: string, listener: (newValue: any, oldValue: any) -> ()) -> (), 
	ListenToArrayInsert: (self: Replica, path: string, listener: (index: number, value: any) -> ()) -> (),
	ListenToArraySet: (self: Replica, path: string, listener: (index: number, value: any) -> ()) -> (),
	ListenToArrayRemove: (self: Replica, path: string, listener: (index: number, value: any) -> ()) -> (),
}

return nil
