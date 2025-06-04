import Std.Random.*;
import Std.Math.*;
import Std.Diagnostics.DumpMachine;

@EntryPoint()
operation Circ() : Unit {
    let b = 0.5 * ArcCos(1.0 / Sqrt(3.0));
    use q = Qubit[5];
    use state = Qubit();

    T0_state(b, 0.0, state);
    DumpMachine();
    Reset(state);

    let err = 0.1;
    mutable syndrom = false;
    repeat{
        ResetAll(q);

        T0_state(b, DrawRandomDouble(-err, err), q[0]);
        T0_state(b, DrawRandomDouble(-err, err), q[1]);
        T0_state(b, DrawRandomDouble(-err, err), q[2]);
        T0_state(b, DrawRandomDouble(-err, err), q[3]);
        T0_state(b, DrawRandomDouble(-err, err), q[4]);

        error_correction_decoder(q);
        let r1 = M(q[1]);
        let r2 = M(q[2]);
        let r3 = M(q[3]);
        let r4 = M(q[4]);
        syndrom = r1 == Zero and r2 == Zero and r3 == Zero and r4 == Zero;

        if syndrom {
            Message("success");
        } else {
            Message("fail");
        }
    }
    until syndrom;

    H(q[0]);
    Y(q[0]);

    DumpMachine();

    H(state);
    CNOT(state, q[0]);
    let result = M(q[0]);

    if result == One {
        S(state);
        X(state);
    }

    DumpMachine();
    ResetAll(q);
    Reset(state);
}

operation T0_state(b: Double, err: Double, q: Qubit) : Unit {
    Ry(2.0 * (b + err), q);
    T(q);
}

operation error_correction_decoder(q: Qubit[]) : Unit {
    CNOT(q[1], q[0]);
    CZ(q[1], q[0]);
    CZ(q[1], q[2]);
    CZ(q[1], q[4]);

    CNOT(q[2], q[0]);
    CZ(q[2], q[3]);
    CZ(q[2], q[3]);

    CNOT(q[3], q[0]);

    CNOT(q[4], q[0]);
    CZ(q[4], q[0]);

    Z(q[0]);
    Z(q[1]);
    Z(q[4]);

    H(q[1]);
    H(q[2]);
    H(q[3]);
    H(q[4]);
}
