import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('manager', Path(__file__).parents[1] / 'lib/manager.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class RecoveryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(dir=Path.home())
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.state = self.root / 'state'
        self.state.mkdir(mode=0o700)
        self.data = self.root / 'connections.json'
        self.data.write_text('known-good')

    def test_mid_restore_failure_recovers_current_data(self):
        snapshot = m.backup([self.data], self.state)
        self.data.write_text('current')
        original = m.apply
        count = 0

        def fail_once(path, data):
            nonlocal count
            count += 1
            if count == 1:
                self.data.write_text('partial')
                raise OSError('injected failure')
            return original(path, data)

        with patch.object(m, 'apply', side_effect=fail_once):
            with self.assertRaises(OSError):
                m.restore(snapshot, [self.data], self.state)
        self.assertEqual(self.data.read_text(), 'current')

    def test_interruption_recovers_current_data(self):
        snapshot = m.backup([self.data], self.state)
        self.data.write_text('current')
        original = m.apply
        count = 0

        def interrupt_once(path, data):
            nonlocal count
            count += 1
            if count == 1:
                self.data.write_text('partial')
                raise KeyboardInterrupt()
            return original(path, data)

        with patch.object(m, 'apply', side_effect=interrupt_once):
            with self.assertRaises(KeyboardInterrupt):
                m.restore(snapshot, [self.data], self.state)
        self.assertEqual(self.data.read_text(), 'current')
        # Read the pre-change recovery snapshot as after an uncatchable interruption.
        import json
        recovery = Path(json.loads((self.state / 'rollback.json').read_text())['backup'])
        original(recovery, m.load_backup(recovery, [self.data], self.state))
        self.assertEqual(self.data.read_text(), 'current')

    def test_copy_failure_never_publishes_partial_backup(self):
        with patch.object(m, 'copy', side_effect=PermissionError()):
            with self.assertRaises(PermissionError):
                m.backup([self.data], self.state)
        self.assertEqual(list(self.state.iterdir()), [])

    def test_running_application_refuses_backup(self):
        with patch.object(m, 'running', return_value=True):
            with self.assertRaises(ValueError):
                m.backup([self.data], self.state)

    def test_manifest_cannot_redirect_restore(self):
        snapshot = m.backup([self.data], self.state)
        with self.assertRaises(ValueError):
            m.load_backup(snapshot, [self.root / 'other'], self.state)

    def test_missing_target_round_trip(self):
        absent = self.root / 'missing'
        snapshot = m.backup([absent], self.state)
        absent.write_text('new')
        m.restore(snapshot, [absent], self.state)
        self.assertFalse(absent.exists())

    def test_hardlinked_file_rejected(self):
        os.link(self.data, self.root / 'link')
        with self.assertRaises(ValueError):
            m.backup([self.data], self.state)


if __name__ == '__main__':
    unittest.main()
